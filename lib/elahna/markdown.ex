defmodule Elahna.Markdown do
  @block_tag_names ~w[div p ul ol li table blockquote pre h1 h2 h3 h4 h5 h6
                      section article main header footer nav aside form]
  @block_tags ~r/<(#{Enum.join(@block_tag_names, "|")})\b[^>]*>/i

  def to_html(content) do
    content
    |> preprocess_and_render()
    |> case do
      {:ok, html, messages} -> {:ok, html, messages}
      {:error, html, messages} -> {:error, html, messages}
    end
  end

  def to_html!(content) do
    case to_html(content) do
      {:ok, html, _} ->
        html

      {:error, html, messages} ->
        IO.puts(:stderr, "Earmark errors: #{inspect(messages)}")
        html
    end
  end

  defp preprocess_and_render(content) do
    parts = Regex.split(@block_tags, content, include_captures: true)

    {results, messages} =
      Enum.map_reduce(parts, [], fn part, acc ->
        if Regex.match?(@block_tags, part) || part == "" do
          {part, acc}
        else
          {html, msgs} = render_part(part, is_block_content?(part))
          {html, acc ++ msgs}
        end
      end)

    html = Enum.join(results)

    if Enum.empty?(messages) do
      {:ok, html, []}
    else
      {:error, html, messages}
    end
  end

  defp is_block_content?(part) do
    trimmed = String.trim(part)

    String.starts_with?(trimmed, ["#", "-", "*", "1.", "```", ">"]) or
      trimmed =~ ~r/^##/ or
      (trimmed =~ ~r/\n.*#/ and trimmed =~ ~r/#\w+/)
  end

  defp render_part(part, is_block) do
    case Earmark.as_html(part, escape: false, smartypants: false) do
      {:ok, html, msgs} ->
        {clean_html(html, is_block), msgs}

      {:error, html, msgs} ->
        {clean_html(html, is_block), msgs}
    end
  end

  defp clean_html(html, false) do
    html
    |> String.replace(~r/^<p>\s*/, "")
    |> String.replace(~r/\s*<\/p>\n$/, "")
  end

  defp clean_html(html, true), do: html
end
