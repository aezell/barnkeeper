defmodule Barnkeeper.Media.S3Uploader do
  @moduledoc """
  S3 uploader for handling photo uploads to AWS S3.
  """

  alias ExAws.S3

  defp bucket, do: Application.get_env(:barnkeeper, :s3_bucket)
  defp region, do: Application.get_env(:barnkeeper, :s3_region, "us-east-1")

  @doc """
  Uploads a file to S3 and returns the public URL.
  """
  def upload_file(file_path, key, content_type) do
    with {:ok, file_binary} <- File.read(file_path),
         {:ok, _response} <- upload_binary(file_binary, key, content_type) do
      {:ok, public_url(key)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Uploads binary data to S3 and returns the public URL.
  """
  def upload_binary(file_binary, key, content_type) do
    S3.put_object(bucket(), key, file_binary, content_type: content_type)
    |> ExAws.request()
    |> case do
      {:ok, _response} -> {:ok, public_url(key)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Generates a unique key for the S3 object.
  """
  def generate_key(horse_id, original_filename) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    random_string = :crypto.strong_rand_bytes(8) |> Base.encode32(case: :lower, padding: false)
    extension = Path.extname(original_filename)

    "horses/#{horse_id}/#{timestamp}_#{random_string}#{extension}"
  end

  @doc """
  Returns the public URL for an S3 object.
  """
  def public_url(key) do
    "https://#{bucket()}.s3.#{region()}.amazonaws.com/#{key}"
  end

  @doc """
  Deletes a file from S3.
  """
  def delete_file(key) do
    S3.delete_object(bucket(), key)
    |> ExAws.request()
  end

  @doc """
  Extracts the S3 key from a full S3 URL.
  """
  def extract_key_from_url(url) do
    case String.split(url, ".amazonaws.com/", parts: 2) do
      [_domain, key] -> key
      _ -> nil
    end
  end

  @doc """
  Gets the configured S3 bucket name.
  """
  def get_bucket, do: bucket()

  @doc """
  Gets the configured S3 region.
  """
  def get_region, do: region()
end
