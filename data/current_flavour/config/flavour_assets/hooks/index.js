/*
This file was generated by the Surface compiler.
*/

function ns(hooks, nameSpace) {
  const updatedHooks = {}
  Object.keys(hooks).map(function(key) {
    updatedHooks[`${nameSpace}#${key}`] = hooks[key]
  })
  return updatedHooks
}

import * as c1 from "./Bonfire.UI.Common.ViewCodeLive.hooks"
import * as c2 from "./Bonfire.UI.Common.PreviewContentLive.hooks"
import * as c3 from "./Bonfire.UI.Common.NotificationLive.hooks"
import * as c4 from "./Bonfire.UI.Common.LoadMoreLive.hooks"
import * as c5 from "./Bonfire.UI.Common.ChangeLocaleLive.hooks"
import * as c6 from "./Bonfire.UI.Common.ChangeThemesLive.hooks"
import * as c7 from "./Bonfire.UI.Common.ComposerLive.hooks"

let hooks = Object.assign(
  ns(c1, "Bonfire.UI.Common.ViewCodeLive"),
  ns(c2, "Bonfire.UI.Common.PreviewContentLive"),
  ns(c3, "Bonfire.UI.Common.NotificationLive"),
  ns(c4, "Bonfire.UI.Common.LoadMoreLive"),
  ns(c5, "Bonfire.UI.Common.ChangeLocaleLive"),
  ns(c6, "Bonfire.UI.Common.ChangeThemesLive"),
  ns(c7, "Bonfire.UI.Common.ComposerLive")
)

export default hooks
