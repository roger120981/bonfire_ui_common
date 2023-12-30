defmodule Bonfire.UI.Common.Testing.Helpers do
  use Surface.LiveViewTest
  import Phoenix.LiveViewTest
  import ExUnit.Assertions
  import Plug.Conn
  import Phoenix.ConnTest
  # import Untangle
  alias Bonfire.Common.Utils
  alias Bonfire.Me.Users
  alias Bonfire.Data.Identity.Account
  alias Bonfire.Data.Identity.User
  alias Surface.Components.Dynamic
  # alias Surface.Components.Context
  alias Bonfire.Common.TestInstanceRepo

  @endpoint Application.compile_env!(:bonfire, :endpoint_module)

  def fake_account!(attrs \\ %{}, opts \\ []),
    do: Bonfire.Me.Fake.fake_account!(attrs, opts)

  def fake_user!(account \\ %{}, attrs \\ %{}, opts \\ []),
    do: Bonfire.Me.Fake.fake_user!(account, attrs, opts)

  def fancy_fake_user!(name, opts \\ []) do
    # repo().delete_all(ActivityPub.Object)
    id = Pointers.ULID.generate()
    user = fake_user!("#{name} #{id}", opts ++ [id: id], opts)
    display_username = Bonfire.Me.Characters.display_username(user, true)

    [
      user: user,
      username: display_username,
      url_on_local:
        "@" <>
          display_username <>
          "@" <> Bonfire.Common.URIs.base_domain(Bonfire.Me.Characters.character_url(user)),
      canonical_url: Bonfire.Me.Characters.character_url(user),
      friendly_url:
        "#{Bonfire.Common.URIs.base_url()}#{Bonfire.Common.URIs.path(user) || "/@#{display_username}"}"
    ]
  end

  def fancy_fake_user_on_test_instance(opts \\ []) do
    TestInstanceRepo.apply(fn -> fancy_fake_user!("Remote", opts) end)
  end

  def fake_admin!(account \\ %{}, attrs \\ %{}, opts \\ []) do
    user = fake_user!(account, attrs, opts)
    {:ok, user} = Users.make_admin(user)
    user
  end

  def fake_user_and_conn!(account \\ fake_account!()) do
    user = fake_user!(account)
    conn = conn(account: account, user: user)
    {user, conn}
  end

  @doc """
  Render stateless Surface or LiveView components
  """
  def render_stateless(component, assigns \\ [], context \\ []) do
    assigns = assigns |> Enum.into(%{__context__: context})

    render_surface do
      ~F"""
      <StatelessComponent module={component} function={:render} {...assigns} />
      """
    end
  end

  @doc """
  Render stateful Surface or LiveView components
  """
  def render_stateful(component, assigns \\ %{}, context \\ []) do
    assigns = assigns |> Enum.into(%{__context__: context})

    render_surface do
      ~F"""
      <StatefulComponent
        module={component}
        id={Utils.e(assigns, :id, nil) || Pointers.ULID.generate()}
        {...assigns}
      />
      """
    end
  end

  @doc """
  Wait for the LiveView to receive any queued PubSub broadcasts
  """
  def live_pubsub_wait(live_view) do
    # see https://elixirforum.com/t/testing-liveviews-that-rely-on-pubsub-for-updates/40938/5
    _ = :sys.get_state(live_view.pid)
  end

  @doc """
  Stop a specific LiveView
  """
  def live_view_stop(view) do
    # see https://elixirforum.com/t/testing-liveview-and-presence-how-to-simulate-a-user-has-left-e-g-closed-tab/58296/10
    GenServer.stop(view.pid())
  end

  @doc """
  Disconnect all LiveViews associated with current user or account
  """
  def live_sockets_disconnect(context) do
    # see https://hexdocs.pm/phoenix_live_view/security-model.html#disconnecting-all-instances-of-a-live-user
    Bonfire.UI.Me.LogoutController.disconnect_sockets(context)
  end

  def session_conn(conn \\ build_conn()),
    do: Plug.Test.init_test_session(conn, %{})

  def conn(), do: conn(session_conn(), [])
  def conn(%Plug.Conn{} = conn), do: conn(conn, [])
  def conn(filters) when is_list(filters), do: conn(session_conn(), filters)

  def conn(conn, filters) when is_list(filters),
    do: Enum.reduce(filters, conn, &conn(&2, &1))

  def conn(conn, {:account, %Account{id: id}}),
    do: put_session(conn, :current_account_id, id)

  def conn(conn, {:account, account_id}) when is_binary(account_id),
    do: put_session(conn, :current_account_id, account_id)

  def conn(conn, {:user, %User{id: id}}),
    do: put_session(conn, :current_user_id, id)

  def conn(conn, {:user, user_id}) when is_binary(user_id),
    do: put_session(conn, :current_user_id, user_id)

  def find_flash(view_or_doc) do
    messages = Floki.find(view_or_doc, ".app_notifications .flash [data-id='flash']")
    # |> info()

    case messages do
      [_, _ | _] -> throw(:too_many_flashes)
      short -> short
    end
  end

  def assert_flash(%Phoenix.LiveViewTest.View{} = view, kind, message) do
    assert_flash(render(view), kind, message)
  end

  def assert_flash(html, kind, message) do
    assert_flash_message(html, message)
    # FIXME:
    # assert_flash_kind(html, kind)
  end

  def assert_flash_kind(flash, :error) do
    id = floki_attr(flash, "data-type")
    assert "error" in id
  end

  def assert_flash_kind(flash, :info) do
    id = floki_attr(flash, "data-type")
    assert "info" in id
  end

  def assert_flash_message(flash, %Regex{} = r),
    do: assert(Floki.text(flash) =~ r)

  def assert_flash_message(flash, bin) when is_binary(bin),
    do: assert(Floki.text(flash) =~ bin)

  def find_form_error(doc, name),
    do: Floki.find(doc, "span.invalid-feedback[phx-feedback-for='#{name}']")

  def assert_field_good(doc, name) do
    assert [field] = Floki.find(doc, "#" <> name)
    assert [] == find_form_error(doc, name)
    field
  end

  def assert_field_error(doc, name, error) do
    assert [field] = Floki.find(doc, "#" <> name)
    assert [err] = find_form_error(doc, name)
    assert Floki.text(err) =~ error
    field
  end

  ### floki_attr

  def floki_attr(elem, :class),
    do:
      Enum.flat_map(
        floki_attr(elem, "class"),
        &String.split(&1, ~r/\s+/, trim: true)
      )

  def floki_attr(elem, attr) when is_binary(attr),
    do: Floki.attribute(elem, attr)

  def floki_response(conn, code \\ 200) do
    assert {:ok, html} = Floki.parse_document(html_response(conn, code))
    html
  end

  defp do_live(conn, nil), do: live(conn)
  defp do_live(conn, path) when is_binary(path), do: live(conn, path)
  defp do_live(conn, path), do: live(conn, Bonfire.Common.URIs.path(path))

  def floki_live(%Plug.Conn{} = conn \\ conn(), path \\ nil) do
    assert {:ok, view, html} = do_live(conn, path)
    assert {:ok, doc} = Floki.parse_document(html)
    {view, doc}
  end

  def floki_redirect(%Plug.Conn{} = conn \\ conn(), path \\ nil) do
    assert {:error, {:live_redirect, %{to: to}}} = do_live(conn, path)
    to
  end

  def floki_click(conn_or_view \\ conn(), path_or_value \\ %{}, value \\ %{})

  def floki_click(%Plug.Conn{} = conn, path, value) do
    {view, _doc} = floki_live(conn, path)
    floki_click(view, value)
  end

  def floki_click(view, value, _) do
    assert {:ok, doc} = Floki.parse_fragment(render_click(view, value))
    doc
  end

  def floki_submit(
        conn_or_view \\ conn(),
        path_or_event,
        event_or_value \\ %{},
        value \\ %{}
      )

  def floki_submit(%Plug.Conn{} = conn, path, event, value) do
    {view, _doc} = floki_live(conn, path)
    floki_submit(view, event, value)
  end

  def floki_submit(view, event, value, _) do
    assert {:ok, doc} = Floki.parse_fragment(render_submit(view, event, value))
    doc
  end
end
