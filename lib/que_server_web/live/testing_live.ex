defmodule QueServerWeb.TestingLive do
  use QueServerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("join-random-chat", _, socket) do
    random_slug = "/" <> MnemonicSlugs.generate_slug(4)

    {:noreply, push_navigate(socket, to: random_slug)}
  end
end
