import "./styles/main.css";
import "./styles/navigation.css";
import "./styles/actions.css";
import "./styles/summary.css";
import "./styles/add.css";
import "./styles/categories.css";
import { Elm } from './elm/Main.elm';
import registerServiceWorker from './registerServiceWorker';

Elm.Main.init({
  node: document.getElementById('root')
});

registerServiceWorker();
