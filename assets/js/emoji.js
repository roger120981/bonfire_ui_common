let EmojiHooks = {};

import insertText from 'insert-text-at-cursor';
import { createPopup } from '@picmo/popup-picker';



EmojiHooks.EmojiPicker = {
  
  mounted() {
    const trigger = document.querySelector('.emoji-button');
    trigger.addEventListener('click', () => {
      picker.toggle();
    });

    const picker = createPopup({}, {
      referenceElement: trigger,
      triggerElement: trigger,
      emojiSize: '1.75rem',
      className: 'z-[9999]',
    });
    

    // picker.addEventListener('emoji:select', event => {
    //   const target_field = document.querySelector(this.el.dataset.targetField || ".composer");
    //   this.pushEvent("emoji-selected", { emoji: event.emoji })
    //   // if (target_field){ 
    //   //     // if area is not focused, focus it
    //   //     if (!target_field.matches(":focus")) {
    //   //       target_field.focus();
    //   //     }
      
    //   //   // Insert the emoji at the cursor position        
    //   //     insertText(target_field, event.emoji + " ")
      
    //   //     // close the emojipicker adding style="display: none;"
    //   //     // document.querySelector(".emoji-picker").setAttribute("style", "display: none;")
    //   //   } else {     
    //   //       console.log("dunno where to insert the emoji")
    //   //   }
    // });

    }

}

export { EmojiHooks }