let ThemeHooks = {};

// import { themeChange } from "theme-change"
import 'vanilla-colorful/hex-color-picker.js';
import 'vanilla-colorful/hex-input.js';

// run to load previously chosen theme when first loading any page (note: not need if using data-theme param on HTML wrapper instead)
// themeChange()

// ThemeHooks.Themeable = {

//     mounted() {
//         // run on a view/component with theme-changing controls (wrapper should have phx-hook="Themeable")
//         themeChange(false) 
//     },

// }

ThemeHooks.ColourPicker = {

    mounted() {
        const id = this.el.id;
        const picker = this.el.querySelector('hex-color-picker');
        const input = this.el.querySelector('hex-input');
        const scope = this.el.dataset.scope;
        var count = 0;
        var debounceCount = 0;
        var debounce;

        let value = input.color.replace("#", "")
        picker.color = value;
        // input.style.backgroundColor = "#" + value;


        const maybe_set = function (hook) {
            console.log("maybe_set")
            // Alpine.debounce(() => this.set(), 500)
            // Alpine.throttle(() => this.set(), 500)

            // Update the count by 1
            count++;

            // Clear any existing debounce event
            clearTimeout(debounce);

            // Update and log the counts after 3 seconds
            debounce = setTimeout(function () {

                // Update the debounceCount
                debounceCount++;

                // do the thing
                console.log("set")
                hook.pushEvent("Bonfire.Me.Settings:put", { keys: "ui:theme:custom:" + id, value: value, scope: scope })

            }, 1000);
            
            // input.style.backgroundColor = "#" + value;
        }

        picker.addEventListener('color-changed', (event) => {
            value = event.detail.value;
            input.color = value;
            maybe_set(this)
        });

        input.addEventListener('color-changed', (event) => {
            value = event.detail.value;
            picker.color = value;
            maybe_set(this)
        });	


    },

}

export { ThemeHooks }