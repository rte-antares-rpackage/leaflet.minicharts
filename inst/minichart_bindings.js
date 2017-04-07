// Copyright © 2016 RTE Réseau de transport d’électricité

LeafletWidget.methods.addMinicharts = function(options, data, maxValues, colorPalette) {
  for (var i = 0; i < options.lng.length; i++) {
    var opt = {};
    for (var k in options) {
      if (options.hasOwnProperty(k)) opt[k] = options[k][i];
    }

    if (data) {
      opt.data = data[i];
      if (opt.data.length > 1) opt.labelText = null;
    }
    if (maxValues) opt.maxValues = maxValues;
    if (colorPalette) opt.colors = colorPalette;

    var l = L.minichart([options.lat[i], options.lng[i]], opt);

    // Keep a reference of colors and data for later use.
    l.fillColor = opt.fillColor || "blue";
    l.colorPalette = colorPalette || ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
                                      "#8c564b", "e377c2", "#7f7f7f", "#bcbd22", "#17becf"];
    l.data = data[i];

    if (options.popup) l.bindPopup(options.popup[i]);

    var id = options.layerId ? options.layerId[i] : undefined;
    this.layerManager.addLayer(l, "minichart", id);
  }
};

LeafletWidget.methods.updateMinicharts = function(options, data, maxValues, colorPalette) {
  for (var i = 0; i < options.layerId.length; i++) {
    var l = this.layerManager.getLayer("minichart", options.layerId[i]);

    var opt = {};
    for (var k in options) {
      if (options.hasOwnProperty(k)) opt[k] = options[k][i];
    }

    if (data) {
      l.data = data[i];
      opt.data = data[i];
    }

    if (maxValues) opt.maxValues = maxValues;

    if (options.popup) l.bindPopup(options.popup[i]);

    if (colorPalette) l.colorPalette = colorPalette;
    if (opt.fillColor) l.fillColor = opt.fillColor;
    if (l.data.length == 1) opt.colors = l.fillColor;
    else opt.colors = l.colorPalette;
    l.setOptions(opt);
  }
};
