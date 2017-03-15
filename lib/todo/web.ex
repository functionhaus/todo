defmodule Todo.Web do
  use Plug.Router

  plug :match
  plug :dispatch

  def start_server do
    case Application.get_env(:todo, :port) do
      nil -> raise("Todo port not specified!")
      port -> Plug.Adapters.Cowboy.http(__MODULE__, nil, port: port)
    end
  end

  post "/add_entry" do
    conn
    |> Plug.Conn.fetch_query_params
    |> add_entry
    |> respond
  end

  post "/entries" do
    conn
    |> Plug.Conn.fetch_query_params
    |> get_entries
    |> respond
  end

  defp get_entries(conn) do
    entries = conn.params["list"]
    |> Todo.Cache.server_process
    |> Todo.Server.get_entries(
      parse_date(conn.params["date"])
    )
    |> format_entries

    Plug.Conn.assign(conn, :response, entries)
  end

  defp add_entry(conn) do
    conn.params["list"]
    |> Todo.Cache.server_process
    |> Todo.Server.add_entry(
      %{
        date: parse_date(conn.params["date"]),
        title: conn.params["title"]
      }
    )

    Plug.Conn.assign(conn, :response, "OK")
  end

  defp respond(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, conn.assigns[:response])
  end

  defp parse_date(yyyymmdd) do
    ~r/(\d{4})(\d{2})(\d{2})/
    |> Regex.run(yyyymmdd, capture: :all_but_first)
    |> List.to_tuple
  end

  defp format_entries(entries) do
    Enum.reduce(entries, "", fn(entry, acc) ->
      {year, month, day} = entry.date
      acc <> "#{year}-#{month}-#{day}    #{entry.title}\n"
    end)
  end
end
