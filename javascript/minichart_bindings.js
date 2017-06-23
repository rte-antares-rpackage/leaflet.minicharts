// Copyright © 2016 RTE Réseau de transport d’électricité

(function() {
  'use strict';

  var utils = require("./utils");
  var d3 = require("d3");

  LeafletWidget.methods.addMinicharts = function(options, data, maxValues, colorPalette, timeLabels, initialTime, popupArgs, onChange) {
    var self = this;
    var timeId = utils.initTimeSlider(this, timeLabels, initialTime);

    // Add method to update time
    utils.addSetTimeIdMethod("Minichart", "setOptions");

    // Create and add minicharts to the map
    utils.processOptions(options, function(opts, i, staticOpts) {
      for (var t = 0; t < opts.length; t++) {
        if (data) {
          opts[t].data = data[i][t];
        }

        if(popupArgs.supValues) {
          opts[t].popupData = popupArgs.supValues[i][t];
        }

        if(popupArgs.html) {
          opts[t].popupHTML = popupArgs.html[i][t];
        }

        if (maxValues) opts[t].maxValues = maxValues;

        if (!opts[t].data || opts[t].data.length == 1) {
          opts[t].colors = opts[t].fillColor || staticOpts.fillColor || d3.schemeCategory10[0];
        } else {
          opts[t].colors = colorPalette || d3.schemeCategory10;
        }
      }

      var l = L.minichart(
        [staticOpts.lat, staticOpts.lng],
        utils.getInitOptions(opts, staticOpts, timeId)
      );
      if (onChange) {
        l.onChange = onChange;
        l.onChange(utils.getInitOptions(opts, staticOpts, timeId));
      }

      // Keep a reference of colors and data for later use.
      l.opts = opts;
      l.colorPalette = colorPalette || d3.schemeCategory10;
      l.timeId = timeId;
      l.popupArgs = popupArgs;
      if (staticOpts.layerId.indexOf("_minichart") != 0) l.layerId = staticOpts.layerId;

      // Popups
      utils.setPopup(l, timeId);

      self.layerManager.addLayer(l, "minichart", staticOpts.layerId);
    });
  };

  LeafletWidget.methods.updateMinicharts = function(options, data, maxValues, colorPalette, timeLabels, initialTime, popupArgs, legendLab, onChange) {
    var self = this;
    var timeId = utils.initTimeSlider(this, timeLabels, initialTime);

    utils.processOptions(options, function(opts, i, staticOpts) {
      var l = self.layerManager.getLayer("minichart", staticOpts.layerId);
      if (popupArgs) l.popupArgs = popupArgs;
      else if(data && legendLab) {l.popupArgs.labels = legendLab}

      for (var t = 0; t < opts.length; t++) { // loop over time steps
        if (data) {
          opts[t].data = data[i][t];
        } else {
          if (l.opts[t]) opts[t].data = l.opts[t].data;
        }

        if (popupArgs && popupArgs.supValues) {
          opts[t].popupData = popupArgs.supValues[i][t];
        } else {
          if (l.opts[t]) opts[t].popupData = l.opts[t].popupData;
        }
        if (popupArgs && popupArgs.html) {
          opts[t].popupHTML = popupArgs.html[i][t];
        } else {
          if (l.opts[t]) opts[t].popupHTML = l.opts[t].popupHTML;
        }

        if (opts[t].data.length == 1) {
          if (opts[t].fillColor) opts[t].colors = opts[t].fillColor
          else if (l.opts[t] && l.opts[t].fillColor) opts[t].colors = l.opts[t].fillColor;
          else opts[t].colors = l.opts[0].fillColor;
        } else opts[t].colors = l.colorPalette;

        if (maxValues) opts[t].maxValues = maxValues;
      }

      l.opts = opts;
      l.setOptions(utils.getInitOptions(opts, staticOpts, timeId));
      if (onChange) {
        l.onChange = onChange;
      }
      if (l.onChange) l.onChange(utils.getInitOptions(opts, staticOpts, timeId));

      utils.setPopup(l, timeId);
    });
  };

  utils.addRemoveMethods("Minichart", "minichart");
}());
