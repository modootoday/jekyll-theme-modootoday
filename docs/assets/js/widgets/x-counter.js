// Docs demo widget (modootoday.scripts.counter, element: x-counter): a button that counts up from props.start by props.step.
// Its controls go after the light-DOM fallback, which the theme hides once the element is defined.
import { readConfig } from "../modootoday/dom/config.js";

class XCounter extends HTMLElement {
  connectedCallback() {
    if (this.querySelector(".x-counter")) {
      return;
    }
    const { props } = readConfig(this, { props: {} });
    const step = Number(props.step) || 1;
    let count = Number(props.start) || 0;
    const box = document.createElement("div");
    box.className = "x-counter";
    const button = document.createElement("button");
    button.type = "button";
    button.textContent = props.label || "Count";
    const output = document.createElement("output");
    output.setAttribute("aria-live", "polite");
    output.value = String(count);
    button.addEventListener("click", () => {
      count += step;
      output.value = String(count);
    });
    box.append(button, output);
    this.append(box);
  }
}

customElements.define("x-counter", XCounter);
