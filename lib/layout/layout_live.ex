defmodule Bonfire.UI.Common.LayoutLive do
  @moduledoc """
  A simple Surface stateless component that sets default assigns needed for every view (eg. used in nav) and then shows some global components and the @inner_content
  """
  use Bonfire.UI.Common.Web, :stateless_component

  alias Bonfire.UI.Common.PersistentLive

  def render(assigns) do
    # Note: since this is not a Surface component, we need to set default props this way
    # TODO: make this list of assigns config-driven so other extensions can add what they need?
    assigns =
      assigns
      # |> debug
      |> assign(to_boundaries: boundaries_or_default(e(assigns, :to_boundaries, nil), assigns))
      |> assign_new(:nav_header, fn -> nil end)
      |> assign_new(:hero, fn -> nil end)
      |> assign_new(:page_title, fn -> nil end)
      |> assign_new(:full_page, fn -> false end)
      |> assign_new(:page, fn -> nil end)
      |> assign_new(:selected_tab, fn -> nil end)
      |> assign_new(:notification, fn -> nil end)
      |> assign_new(:page_header_aside, fn -> nil end)
      |> assign_new(:custom_page_header, fn -> nil end)
      |> assign_new(:inner_content, fn -> nil end)
      |> assign_new(:object_id, fn -> nil end)
      |> assign_new(:post_id, fn -> nil end)
      |> assign_new(:context_id, fn -> nil end)
      |> assign_new(:reply_to_id, fn -> nil end)
      |> assign_new(:create_object_type, fn -> nil end)
      |> assign_new(:nav_items, fn -> nil end)
      |> assign_new(:current_app, fn -> nil end)
      |> assign_new(:current_account_id, fn -> nil end)
      |> assign_new(:current_user_id, fn -> nil end)
      |> assign_new(:to_circles, fn -> [] end)
      |> assign_new(:smart_input_opts, fn ->
        [
          as: Bonfire.UI.Common.SmartInputLive.set_smart_input_as(assigns[:thread_mode], assigns)
        ]
      end)
      |> assign_new(:showing_within, fn -> nil end)
      |> assign_new(:sidebar_widgets, fn -> [] end)
      |> assign_new(:without_sidebar, fn -> nil end)
      #     fn -> (not is_nil(current_user(assigns)) &&
      #         empty?(e(assigns, :sidebar_widgets, :users, :main, nil))) ||
      #        (!is_nil(current_user(assigns)) &&
      #           empty?(e(assigns, :sidebar_widgets, :guests, :main, nil)))
      # end)
      |> assign_new(:thread_mode, fn -> nil end)
      |> assign_new(:show_less_menu_items, fn -> false end)

    ~F"""
    <div data-id="bonfire_live" class="transition duration-150 ease-in-out transform">
      <Bonfire.UI.Common.PreviewContentLive id="preview_content" />

      <div
        x-data="{
          open_sidebar_drawer: false,
          width: window.innerWidth,
        }"
        @resize.window.debounce.100="width = window.innerWidth"
        class={
          "w-full widget items-start mx-auto grid grid-cols-1 max-w-[1280px] md:grid-cols-[260px_1fr_320px]",
          "!grid-cols-1 !max-w-full": @without_sidebar || is_nil(@current_user),
          "mt-[65px]": @nav_header != false
        }
      >
        <PersistentLive
          id={:persistent}
          sticky
          container={{:div, class: "contents"}}
          session={%{
            "context" => %{
              sticky: true,
              csrf_token: @csrf_token,
              current_app: @current_app,
              current_user_id: @current_user_id,
              current_account_id: @current_account_id
              # current_app: @__context__[:current_app]
            }
          }}
        />

        <div
          data-id="main_section"
          class={
            "gap-2 md:gap-0 relative z-[105] w-full col-span-1 h-full",
            "!max-w-full": @full_page || @without_sidebar,
            "mx-auto": @without_sidebar
          }
        >
          <div class={
            "h-full mt-0 grid tablet-lg:grid-cols-[1fr] desktop-lg:grid-cols-[1fr] grid-cols-1",
            "md:mt-6": @nav_header == false,
            "max-w-screen-lg gap-4 mx-auto": is_nil(@current_user),
            "justify-between": not is_nil(@current_user)
          }>
            <div class="relative invisible_frame">
              <div class="h-full pb-16 md:pb-0 md:overflow-y-visible md:h-full">
                <div id="inner" class="">
                  <!-- Bonfire.UI.Common.ExtensionHorizontalMenuLive
                page={@page}
                selected_tab={@selected_tab}
                /-->
                  {@inner_content}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- <Bonfire.UI.Common.MobileSmartInputButtonLive
        :if={not is_nil(@current_user) and !@hide_smart_input}
        smart_input_opts={@smart_input_opts}
      /> -->
      <Bonfire.UI.Common.NavFooterMobileUserLive :if={not is_nil(@current_user)} page={@page} />

      <!--      {if module_enabled?(RauversionExtension.UI.TrackLive.Player, @current_user),
        do:
          live_render(@socket, RauversionExtension.UI.TrackLive.Player,
            id: "global-main-player",
            session: %{},
            sticky: true
          )} -->
    </div>

    <Bonfire.UI.Common.ReusableModalLive id="modal" />

    <Bonfire.UI.Common.NotificationLive
      id="notification"
      notification={@notification}
      root_flash={@flash}
    />
    """
  end
end
