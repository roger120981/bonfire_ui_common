import insertText from 'insert-text-at-cursor';
import getCaretCoordinates from 'textarea-caret';



let ComposerHooks = {};

ComposerHooks.ScreenSize = {
  mounted() {
    window.addEventListener("resize", (e) => {
      if (window.innerWidth < 768) {
        this.pushEventTo("#smart_input", "set", {smart_input_as: "focused"});
      } else {
        this.pushEventTo("#smart_input", "set", {smart_input_as: "non_blocking"});
      }
    });

    if (window.innerWidth < 768) {
      this.pushEventTo("#smart_input", "set", {smart_input_as: "focused"});
    }
  }
}

ComposerHooks.Composer = {

    mounted() {
      const MIN_PREFIX_LENGTH = 2
      // Technically mastodon accounts allow dots, but it would be weird to do an autosuggest search if it ends with a dot.
      // Also this is rare. https://github.com/tootsuite/mastodon/pull/6844
      const VALID_CHARS = '[\\w\\+_\\-:]'
      const MENTION_PREFIX = '(?:@)'
      // const HASH_PREFIX = '(?:#)'
      const TOPIC_PREFIX = '(?:\\+)'
      const MENTION_REGEX = new RegExp(`(?:\\s|^)(${MENTION_PREFIX}${VALID_CHARS}{${MIN_PREFIX_LENGTH},})$`)
      const TOPIC_REGEX = new RegExp(`(?:\\s|^)(${TOPIC_PREFIX}${VALID_CHARS}{${MIN_PREFIX_LENGTH},})$`)

      const textarea = this.el.querySelector("textarea")
    // console.log(textarea)
      const suggestions_menu = this.el.querySelector(".menu")
      const container = document.querySelector("#smart_input");


      setFileInput = function (data, input, name, defaultType = "image/jpeg") {
        // console.log(data)
        var split = data.toString().split(";base64,");
        var type = data.type || defaultType;
        var ext = type.split("/")[1];
        // console.log(split)
        file = new File([split[1] || data], name + "." + ext, {
          type: type,
        });
        console.log(file);
        let container = new DataTransfer();
        container.items.add(file);
        input.files = container.files;
        var event = document.createEvent("HTMLEvents"); // bubble up to LV
        event.initEvent("input", true, true);
        input.dispatchEvent(event);
      }

      // Detect if the user is holding shift and the key is enter
      textarea.addEventListener("keydown", (e) => {
        if (e.key === "Enter" && e.shiftKey) {
          // Prevent the default behavior
          e.preventDefault();
          return;
        }
      })

      // Add a listener to the textarea to detect when the user paste an image
      textarea.addEventListener("paste", (e) => {
        // Get the clipboard data
        const clipboardData = e.clipboardData || window.clipboardData;
        // Get the image from the clipboard
        const image = clipboardData.items[0].getAsFile();
        const input = container.querySelector("input[type=file]");
        // If the image is not null
        if (image) {
          setFileInput(image, input, "image")
        }
      })

      // Add a listener to the textarea to detect when the user drag and drop an image
      // textarea.addEventListener("drop", (e) => {
      //   // Get the image from the clipboard
      //   const image = e.dataTransfer.files[0];
      //   const input = container.querySelector("input[type=file]");
      //   // If the image is not null
      //   if (image) {
      //     setFileInput(image, input, "image")
      //   }
      // })
        
      suggestions_menu.addEventListener("click", (e) => {
        // get the data-id attribute from the button child element
        const id = e.target.closest('button').dataset.id
        const inputText = e.target.closest('button').dataset.input
        
        // Remove the previous text from the current cursor position untill a space is found
        const text = textarea.value
        const pos = textarea.selectionStart
        const before = text.substring(0, pos)
        const beforeSpace = before.lastIndexOf(' ')
        const beforeText = before.substring(0, beforeSpace)
        textarea.value = beforeText + ' '
        // Insert the id of the selected user


        insertText(textarea, id + " ")
        textarea.focus()         
      })

      textarea.addEventListener("input", (e) => {  

        // Get the input text from the textarea
        const inputText = textarea.value; 
        // console.log(inputText)

        // Get the mentions from the input text, only if the character is followed by a word character and not an empty space
        const mentions = inputText.match(MENTION_REGEX)
        const topics = inputText.match(TOPIC_REGEX)
      
        let list = ''
        const menu = this.el.querySelector('.menu')
        if(mentions) {
          const text = mentions[0].split('@').pop()
          getFeedItems(text, '@').then(res => {
          // if suggestions is greater than 0 append below textarea a menu with the suggestions
            if (res.length > 0) {
              menu.classList.remove("hidden", false)
              
              var caret = getCaretCoordinates(textarea, textarea.selectionEnd);
              menu.style.top = caret.top + caret.height + 'px'
              menu.style.left = caret.left + 'px'

              let counter = 0;
              res.some((item) => {
                if (counter >= 4) {
                  return true; // Stops the iteration
                }

                list += topicItemRenderer(item);
                counter++;
              });

              // let maxItems = 4
              // for (let i = 0; i < res.length && i < maxItems; i++) {
              //   list += topicItemRenderer(res[i]);
              // }
              // res.forEach((item) => {
              //   list += mentionItemRenderer(item, text)
              // })
            } else {
              menu.classList.add("hidden", false)
              list +=  ` `
            }
            menu.innerHTML = list
          })
          
        } else if (topics) {
          // console.log(topics)
          const text = topics[0].split('+').pop()
          getFeedItems(text, '+').then(res => {
            // if suggestions is greater than 0 append below textarea a menu with the suggestions
              if (res.length > 0) {
                console.log(res.length)
                menu.classList.remove("hidden", false)
                var caret = getCaretCoordinates(textarea, textarea.selectionEnd);
                menu.style.top = caret.top + caret.height + 'px'
                menu.style.left = caret.left + 'px'
                let maxItems = 4
                for (let i = 0; i < res.length && i < maxItems; i++) {
                  list += topicItemRenderer(res[i]);
                }
              } else {
                list +=  ` `
              }
              menu.innerHTML = list
            })
        
          }  else {
          // no suggestions
          list +=  ` `
          menu.innerHTML = list
          menu.classList.add("hidden", false)
        }
    })
  }
}

const mentionItemRenderer = (item, text) => {
  return `
    <li class="flex rounded flex-col py-2 px-3">
      <button class="gap-0 items-start flex flex-col rounded py-1.5" type="button" data-id="${item.id}" data-input="${text}">
        <div class="text-sm truncate max-w-[240px] text-base-content font-semibold">${item.value}</div>
        <div class="text-xs truncate max-w-[240px] text-base-content/70 font-regular">${item.id}</div>
      </button>
    </li>`
}

const topicItemRenderer = (item) => {
  return `
    <li class="flex rounded flex-col py-2 px-3">
      <button class="gap-0 items-start rounded py-1.5 flex flex-col" type="button" data-id="${item.id}">
        <div class="text-sm truncate max-w-[240px] text-base-content font-semibold">${item.value}</div>
        <div class="text-xs truncate max-w-[240px] text-base-content/70 font-regular">${item.id}</div>
      </button>
    </li>`
}



function getFeedItems(queryText, prefix) {
  // console.log(prefix)
  if (queryText && queryText.length > 0) {
    return new Promise((resolve) => {
      // this requires the bonfire_tag extension
      fetch("/api/tag/autocomplete/ck5/" + prefix + "/" + queryText)
        .then((response) => response.json())
        .then((data) => {
          let values = data.map((item) => ({
            id: item.id,
            value: item.name,
            link: item.link,
          }));
          resolve(values);
        })
        .catch((error) => {
          console.error("There has been a problem with the tag search:", error);
          resolve([]);
        });
    });
  } else return [];
}

export { ComposerHooks }