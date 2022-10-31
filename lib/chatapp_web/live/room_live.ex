defmodule ChatappWeb.RoomLive do
  use ChatappWeb, :live_view
  require Logger

  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)

    if connected?(socket) do
      ChatappWeb.Endpoint.subscribe(topic)
      ChatappWeb.Presence.track(self(), topic, username, %{})
    end

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       username: username,
       message: "",
       user_list: [],
       messages: [
        #  %{uuid: UUID.uuid4(), content: "#{username} join the chat!", username: "System"}
       ],
       temporary_message: [messages: []]
     )}
  end

  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    # Logger.info(message: message)
    message = %{uuid: UUID.uuid4(), content: message, username: socket.assigns.username}
    ChatappWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    # Logger.info(message: message)
    {:noreply, assign(socket, message: message)}
  end

  def handle_info(%{event: "new-message", payload: message}, socket) do
    # Logger.info(payload: message)
    {:noreply, assign(socket, messages: [message])}
  end

  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    IO.inspect("================")
    # Logger.info(joins: joins , leaves: leaves)
    joins_message =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system, uuid: UUID.uuid4(), content: "#{username} joined!"}
      end)

    leaves_message =
      leaves
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system, uuid: UUID.uuid4(), content: "#{username} left !!"}
      end)
      user_list = ChatappWeb.Presence.list(socket.assigns.topic)
      |> Map.keys()

        # user_list = ChatappWeb.Presence.get_by_key(socket.assigns.topic, socket.assigns.username)
        # Logger.info(user_list: user_list)
    {:noreply, assign(socket, messages: joins_message ++ leaves_message , user_list: user_list)}
  end

  def display_message(%{type: :system, uuid: uuid, content: content}) do
~E"""
<p id="<%=uuid%>"><em>
<%= content %></em></p>

"""
end
def display_message(%{uuid: uuid,content: content, username: username}) do
  ~E"""
  <p id="<%= uuid %>"><strong><%= username %>:
   </strong><%= content %></p>

  """
end
end
