defmodule Bonfire.UI.Common.InputControlsLive do
  use Bonfire.UI.Common.Web, :stateless_component
  use Bonfire.Common.Utils

  # prop target_component, :string
  prop preloaded_recipients, :list, default: nil
  prop smart_input_opts, :list, default: []
  prop reply_to_id, :any, default: nil
  prop context_id, :string, default: nil
  prop create_object_type, :any, default: nil
  prop to_boundaries, :any, default: nil
  prop to_circles, :list, default: []
  prop showing_within, :any, default: nil
  prop uploads, :any, default: nil
  prop uploaded_files, :list, default: []
  prop thread_mode, :atom, default: nil
  prop page, :any, default: nil
  prop show_cw_toggle, :boolean, default: false
  prop submit_label, :string, default: nil
  prop open_boundaries, :boolean, default: false
  prop show_select_recipients, :boolean, default: false
  prop boundaries_modal_id, :string, default: :sidebar_composer
end
