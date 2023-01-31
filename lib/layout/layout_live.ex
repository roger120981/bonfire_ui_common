defmodule Bonfire.UI.Common.LayoutLive do
  @moduledoc """
  A simple Surface stateless component that sets default assigns needed for every view (eg. used in nav) and then shows some global components and the @inner_content
  """
  use Bonfire.UI.Common.Web, :stateless_component

  alias Bonfire.UI.Common.PersistentLive

  def maybe_custom_theme(context) do
    if Settings.get([:ui, :theme, :preferred], nil, context) == :custom do
      config =
        Enums.stringify_keys(Settings.get([:ui, :theme, :custom], %{}, context))
        |> debug("custom theme config")

      # Cache.maybe_apply_cached(&custom_theme_attr/1, [config])
      custom_theme_attr(config)
    else
      ""
    end
  end

  def custom_theme_attr(config), do: DaisyTheme.style_attr(config) |> debug("custom theme style")

  def render(assigns) do
    # Note: since this is not a Surface component, we need to set default props this way
    # TODO: make this list of assigns config-driven so other extensions can add what they need?
    assigns =
      assigns
      # |> debug
      |> assign_new(:to_boundaries, fn -> nil end)
      # |> assign_new(:hero, fn -> nil end)
      |> assign_new(:page_title, fn -> nil end)
      |> assign_new(:page, fn -> nil end)
      |> assign_new(:selected_tab, fn -> nil end)
      |> assign_new(:notification, fn -> nil end)
      |> assign_new(:page_header_aside, fn -> nil end)
      |> assign_new(:page_header_icon, fn -> nil end)
      # |> assign_new(:custom_page_header, fn -> nil end)
      |> assign_new(:inner_content, fn -> nil end)
      |> assign_new(:back, fn -> false end)
      |> assign_new(:object_id, fn -> nil end)
      |> assign_new(:post_id, fn -> nil end)
      |> assign_new(:context_id, fn -> nil end)
      |> assign_new(:reply_to_id, fn -> nil end)
      |> assign_new(:create_object_type, fn -> nil end)
      |> assign_new(:nav_items, fn -> nil end)
      |> assign_new(:current_app, fn -> nil end)
      |> assign_new(:current_account, fn -> nil end)
      |> assign_new(:current_account_id, fn -> nil end)
      |> assign_new(:current_user, fn -> nil end)
      |> assign_new(:current_user_id, fn -> nil end)
      |> assign_new(:instance_settings, fn -> nil end)
      |> assign_new(:to_circles, fn -> [] end)
      |> assign_new(:smart_input_opts, fn ->
        [
          as: Bonfire.UI.Common.SmartInputLive.set_smart_input_as(assigns[:thread_mode], assigns)
        ]
      end)
      |> assign_new(:showing_within, fn -> nil end)
      |> assign_new(:without_sidebar, fn -> nil end)
      |> assign_new(:without_widgets, fn -> false end)
      |> assign_new(:sidebar_widgets, fn -> [] end)
      #     fn -> (not is_nil(current_user(assigns)) &&
      #         empty?(e(assigns, :sidebar_widgets, :users, :main, nil))) ||
      #        (!is_nil(current_user(assigns)) &&
      #           empty?(e(assigns, :sidebar_widgets, :guests, :main, nil)))
      # end)
      |> assign_new(:thread_mode, fn -> nil end)

    ~F"""
    <div
      data-id="bonfire_live"
      class=""
      style={maybe_custom_theme(
        current_user: @current_user,
        current_account: @current_account,
        instance_settings: @instance_settings
      )}
      x-data="{
          open_sidebar: false
        }"
    >
      <!-- div
        :if={!@current_user or
          (@without_sidebar && empty?(e(assigns, :sidebar_widgets, :guests, :secondary, nil)))}
        class="px-4 tablet-lg:px-0 mb-6 border-b border-base-content/10 sticky top-0 bg-base-300 z-[99999999999999999999999999999]"
      >
        <Bonfire.UI.Common.GuestHeaderLive
          current_user={@current_user}
          current_account={@current_account}
          page_title={@page_title}
          page={@page}
        />
      </div -->

      <div class={
        "w-full px-0 md:px-4 grid max-w-[1260px] gap-0 md:gap-4 widget xl:px-0 mx-auto",
        "!grid-cols-1 content-start": @without_sidebar && @without_widgets,
        # "grid-cols-1 !max-w-full": !@current_user,
        "grid-cols-1 md:grid-cols-[280px_1fr] tablet-lg:grid-cols-[280px_1fr_320px]": !@current_user,
        "grid-cols-1 md:grid-cols-1 content-start !max-w-full":
          @without_sidebar && empty?(e(assigns, :sidebar_widgets, :guests, :secondary, nil)),
        "grid-cols-1 md:grid-cols-[280px_1fr]": @current_user && @without_widgets && !@without_sidebar,
        "grid-cols-1 md:grid-cols-[280px_1fr] tablet-lg:grid-cols-[280px_1fr_320px] ":
          @current_user && !@without_sidebar && !@without_widgets
      }>
        <Bonfire.UI.Common.NavSidebarLive
          :if={!@without_sidebar}
          page={@page}
          selected_tab={@selected_tab}
          nav_items={@nav_items}
          sidebar_widgets={@sidebar_widgets}
        />

        <div
          data-id="main_section"
          class={
            "relative w-full max-w-[1280px]  gap-2 md:gap-0 z-[105] col-span-1 ",
            "!max-w-full": @without_widgets,
            "!max-w-full": !@current_user,
            "mx-auto order-last": @without_sidebar
          }
        >
          <div class={
            "h-full mt-0 grid tablet-lg:grid-cols-[1fr] desktop-lg:grid-cols-[1fr] grid-cols-1",
            "max-w-screen-lg gap-4 mx-auto": @without_widgets,
            "justify-between": !@without_widgets
          }>
            <div class="relative invisible_frame">
              <div class="pb-16 md:pb-0 md:overflow-y-visible">
                <Bonfire.UI.Common.PreviewContentLive id="preview_content" />
                <div
                  id="inner"
                  class={
                    "md:mt-0 bg-base-100 min-h-[calc(var(--inner-window-height)_-_22px)] pb-[1px]":
                      !@without_sidebar
                  }
                >
                  <div :if={!@without_sidebar} class="sticky top-0  md:pt-3 bg-base-300 z-[999]">
                    <div class="flex flex-1 rounded-t bg-base-100" :class="{'hidden': open_sidebar}">
                      <Dynamic.Component
                        module={Bonfire.UI.Common.PageHeaderLive}
                        page_title={@page_title}
                        page_header_icon={@page_header_icon}
                        back={@back}
                        page={@page}
                        selected_tab={@selected_tab}
                      >
                        <:right_action>
                          <Dynamic.Component
                            :if={@page_header_aside}
                            :for={{component, component_assigns} <- e(@page_header_aside, [])}
                            module={component}
                            {...component_assigns}
                          />
                        </:right_action>
                      </Dynamic.Component>
                    </div>
                  </div>

                  {@inner_content}
                </div>
              </div>
            </div>
          </div>
        </div>
        <PersistentLive
          id={:persistent}
          :if={!@without_sidebar}
          sticky
          container={
            {:div, class: "order-first md:order-none md:static fixed left-0 right-0 top-0 z-[999]"}
          }
          session={%{
            "context" => %{
              sticky: true,
              csrf_token: @csrf_token,
              # current_app: @current_app,
              # current_user: @current_user,
              # current_account: @current_account,
              current_user_id: @current_user_id,
              current_account_id: @current_account_id
            }
          }}
        />
      </div>

      <!--      {if module_enabled?(RauversionExtension.UI.TrackLive.Player, @current_user),
        do:
          live_render(@socket, RauversionExtension.UI.TrackLive.Player,
            id: "global-main-player",
            session: %{},
            sticky: true
          )} -->
    </div>

    <Bonfire.UI.Common.ReusableModalLive id="modal" />
    <Bonfire.UI.Common.NotificationLive id={:notification} root_flash={@flash} />
    """
  end
end
