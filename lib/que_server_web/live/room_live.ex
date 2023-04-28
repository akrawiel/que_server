defmodule QueServerWeb.RoomLive do
  use QueServerWeb, :live_view

  use Phoenix.HTML

  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "topic:" <> room_id
    username = MnemonicSlugs.generate_slug(2)

    if connected?(socket) do
      QueServerWeb.Endpoint.subscribe(topic)
      QueServerWeb.Presence.track(self(), topic, username, %{})
    end

    socket =
      assign(socket,
        room_id: room_id,
        form: to_form(%{}, as: :chat),
        topic: topic,
        username: username,
        user_list: [],
        message: "",
        messages: []
      )

    {:ok, socket, temporary_assigns: [messages: []]}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    QueServerWeb.Endpoint.broadcast(socket.assigns.topic, "new_message", %{
      id: UUID.uuid4(),
      content: message,
      username: socket.assigns.username
    })

    socket = assign(socket, message: "")

    {:noreply, socket}
  end

  @impl true
  def handle_event("form_updated", %{"chat" => %{"message" => message}}, socket) do
    socket = assign(socket, message: message)

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "new_message", payload: message}, socket) do
    socket = assign(socket, messages: [message])
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn username -> %{type: :system, id: UUID.uuid4(), content: "#{username}
        joined"} end)

    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn username -> %{type: :system, id: UUID.uuid4(), content: "#{username}
        left"} end)

    user_list = QueServerWeb.Presence.list(socket.assigns.topic)
      |> Map.keys()

    socket = assign(socket, messages: join_messages ++ leave_messages, user_list: user_list)

    {:noreply, socket}
  end

  def message(assigns) when assigns.message.type == :system do
    ~H"""
    <em id={@message.id}>
      <%= @message.content %>
    </em>
    """
  end

  def message(assigns) when assigns.message.username != nil do
    ~H"""
    <div id={@message.id}>
      <strong><%= @message.username %></strong>: <%= @message.content %>
    </div>
    """
  end
end
