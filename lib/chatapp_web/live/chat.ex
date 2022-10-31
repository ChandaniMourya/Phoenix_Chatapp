defmodule ChatappWeb.Chat do
  use ChatappWeb, :live_view
   require Logger

    def mount(_params, _session, socket) do
    {:ok, assign(socket,query: "", results: %{})}
  end
  # def mount(_params, _session, socket) do

  #   socket =
  #   socket
  #   |> assign(
  #     name: "Harsh"
  #   )

  #   {:ok, socket}
  # end

  # def handle_event("change_name", _params, socket) do
  #   new_name = "Chandani"

  #   socket =
  #     socket
  #     |> assign(
  #       name: new_name
  #     )

  #   {:noreply, socket}
  # end

    def handle_event("random-room",_params,socket) do
random_slug ="/" <> MnemonicSlugs.generate_slug(4)
      Logger.info(random_slug)
      {:noreply ,push_redirect(socket, to: random_slug)}
    end
end
