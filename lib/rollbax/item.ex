defmodule Rollbax.Item do
  # Maybe link to docs https://rollbar.com/docs/api/items_post/

  # Maybe add a comment that says we do this to chache the cachable parts of the
  # payload that we keep in the Rollbax.Client's state.

  def draft(token, envt) do
    {:ok, host} = :inet.gethostname
    %{
      "access_token" => token,
      "data" => %{
        "server" => %{
          "host" => List.to_string(host)
        },
        "environment" => envt,
        "language" => language(),
        "platform" => platform(),
        "notifier" => notifier()
      }
    }
  end

  # Maybe a name like "fill_draft"

  def compose(draft, {level, msg, time, meta}) do
    # :rollbax_occurr_data needs docs
    {occurr_data, meta} =
      Map.pop(meta, :rollbax_occurr_data, %{})
    Map.update!(draft, "data", fn(data) ->
      Map.merge(occurr_data, data)
      |> put_body(msg)
      |> put_custom(meta)
      |> Map.put("level", level)
      |> Map.put("timestamp", time)
    end)
  end

  defp put_body(data, msg) do
    Map.put(data, "body", %{"message" => %{"body" => msg}})
  end

  defp put_custom(data, meta) do
    if map_size(meta) == 0 do
      data
    else
      Map.put(data, "custom", meta)
    end
  end

  defp language() do
    "Elixir v" <> System.version
  end

  defp platform() do
    :erlang.system_info(:system_version)
    |> List.to_string
    |> String.strip
  end

  # We can make @project_version similar to push-cartel

  defp notifier() do
    %{
      "name" => "Rollbax",
      "version" => unquote(Mix.Project.config[:version])
    }
  end
end
