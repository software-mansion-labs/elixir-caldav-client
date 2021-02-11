client = %CalDAVClient.Client{
  server_url: "http://127.0.0.1:8800/cal.php",
  auth: :basic,
  username: "username",
  password: "password"
}

calendar_url = CalDAVClient.URL.Builder.build_calendar_url("username", "calendar_demo")

try do
  :ok =
    client
    |> CalDAVClient.Calendar.create(calendar_url,
      name: "Example calendar",
      description: "This is an example calendar."
    )

  :ok =
    client
    |> CalDAVClient.Calendar.update(calendar_url,
      name: "Lorem ipsum",
      description: "Lorem ipsum sit dolot amet."
    )
after
  :ok = client |> CalDAVClient.Calendar.delete(calendar_url)
end
