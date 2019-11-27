/* eslint-disable sort-keys */

import CategoricalScheme from "@superset-ui/color/esm/CategoricalScheme";

const schemes = [
  {
    id: "fnkColors",
    label: "Funky Colors",
    colors: [
      "#ff0000", // rausch
      "#00ff00", // hackb
      "#0000ff", // kazan
      "#ff00ff", // babu
      "#ffff00", // lima
      "#00ffff"
    ]
  }
].map(s => new CategoricalScheme(s));

export default schemes;
