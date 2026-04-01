defmodule ElahnaWeb.FileGuard do
  @moduledoc """
  Security module for sanitizing file paths and preventing directory traversal attacks.
  """

  @doc """
  Sanitizes the filename and ensures it stays within the target directory.
  """
  def safe_path(base_dir, filename) do
    clean_name = Path.basename(filename)

    full_path = Path.join([base_dir, clean_name])

    if File.exists?(full_path) do
      {:ok, full_path}
    else
      {:error, :not_found}
    end
  end
end
