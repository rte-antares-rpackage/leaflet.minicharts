// Copyright © 2016 RTE Réseau de transport d’électricité

(function() {
  'use strict';

  var utils = require("./utils");
  var d3 = require("d3");

  LeafletWidget.methods.addMinicharts = function(options, data, maxValues, colorPalette, timeLabels, initialTime, popup) {
    var self = this;
    var timeId = utils.initTimeSlider(this, timeLabels, initialTime);

    // Add method to update time
    utils.addSetTimeIdMethod("Minichart", "setOptions");

    // Create and add minicharts to the map
    utils.processOptions(options, function(opts, i) {
      for (var t = 0; t < opts.length; t++) {
        if (data) {
          opts[t].data = data[i][t];
        }

        if (maxValues) opts[t].maxValues = maxValues;

        if (!opts[t].data || opts[t].data.length == 1) {
          opts[t].colors = opts[t].fillColor || d3.schemeCategory10[0];
        } else {
          opts[t].colors = colorPalette || d3.schemeCategory10;
        }
      }

      var l = L.minichart([opts[timeId].lat, opts[timeId].lng], opts[timeId]);

      // Keep a reference of colors and data for later use.
      l.opts = opts;
      l.colorPalette = colorPalette || d3.schemeCategory10;
      l.timeId = timeId;

      // Popups
      if (opts[timeId].popup) {
        l.bindPopup(opts[timeId].popup);
      }

      self.layerManager.addLayer(l, "minichart", opts[timeId].layerId);
    });
  };

  LeafletWidget.methods.updateMinicharts = function(options, data, maxValues, colorPalette, timeLabels, initialTime) {
    var self = this;
    var timeId = utils.initTimeSlider(this, timeLabels, initialTime);

    utils.processOptions(options, function(opts, i) {
      var l = self.layerManager.getLayer("minichart", opts[timeId].layerId);

      for (var t = 0; t < opts.length; t++) { // loop over time steps
        if (data) {
          opts[t].data = data[i][t];
        } else {
          opts[t].data = l.opts[t].data;
        }

        if (opts[t].data.length == 1) opts[t].colors = opts[t].fillColor || l.opts[t].fillColor;
        else opts[t].colors = l.colorPalette;

        if (maxValues) opts[t].maxValues = maxValues;
      }

      l.opts = opts;
      l.setOptions(opts[timeId]);

      if (opts[timeId].popup) {
        l.bindPopup(opts[timeId].popup);
      }
    });
  };

  utils.addRemoveMethods("Minichart", "minichart");
}());
