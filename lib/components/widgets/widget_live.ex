defmodule Bonfire.UI.Common.WidgetLive do
  use Bonfire.UI.Common.Web, :stateless_component

  prop widget, :any, required: true
  prop data, :any, default: []
  prop without_icon, :boolean, default: false
  prop text_class, :css_class, required: false, default: "text-sm"
  prop icon_class, :css_class, required: false, default: "w-4 h-4 text-base-content/80"
  prop page, :string, default: nil
  prop selected_tab, :any, default: nil

  def widget(%{name: :extension, app: app}, context) do
    Bonfire.Common.ExtensionModule.extension(app)
  end

  def widget(%{name: :current_extension}, context) do
    context[:current_extension]
  end

  def widget(widget, _context) do
    widget
  end
end
