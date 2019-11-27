/* eslint-disable sort-keys */

import CategoricalScheme from "@superset-ui/color/esm/CategoricalScheme";

const schemes = [
  {
    id: "fnkColors",
    label: "Funky Colors",
    colors: ["#8b94a3", "#dd7500", "#f2bf49", "#d8b511", "#c67f07"]
  }
].map(s => new CategoricalScheme(s));

export default schemes;
