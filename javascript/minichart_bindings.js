// Copyright © 2016 RTE Réseau de transport d’électricité

(function() {
  'use strict';

  LeafletWidget.methods.addMinicharts = function(options, data, maxValues, colorPalette, timeLabels, initialTime, popup) {
    var layerManager = this.layerManager;
    var i, j, k, t; // Variables used in loops

    // Initialize time slider
    var tslider;
    if (!this.controls._controlsById.tslider) {
      tslider = L.timeSlider({
        timeLabels: timeLabels,
        onTimeIdChange: function(timeId) {
          var types = ["minichart", "flow"];
          for (var i = 0; i < types.length; i++) {
            var layers = layerManager._byCategory[types[i]];
            for (var k in layers) {
              if (layers[k]) layers[k].setTimeId(timeId);
            }
          }
        }
      });
      this.controls.add(tslider, "tslider");
    } else {
      tslider = this.controls._controlsById.tslider;
      tslider.setTimeLabels(timeLabels);
    }

    var timeId = tslider.toTimeId(initialTime);
    tslider.setTimeId(timeId);

    // Add method to update time
    if (!L.Minichart.prototype.setTimeId) {
      L.Minichart.prototype.setTimeId = function(timeId) {
        if (timeId == this.timeId) return;

        if (typeof this.opts !== "undefined" && typeof this.opts[timeId] !== 'undefined') {
          var opt = this.opts[timeId];
          this.setOptions(opt);
          if (opt.popup) {
            this.bindPopup(opt.popup);
          }
        }
        this.timeId = timeId;
      };
    }

    // Create and add minicharts to the map
    for (i = 0; i < options.length; i++) { // Lopp over layers
      var opts = [];

      for (t = 0; t < options[i].layerId.length; t++) { // loop over time steps
        var opt = {};
        for (k in options[i]) {
          if (options[i].hasOwnProperty(k)) opt[k] = options[i][k][t];
        }

        if (data) {
          opt.data = data[i][t];
        }

        if (maxValues) opt.maxValues = maxValues;

        if (!opt.data || opt.data.length == 1) {
          opt.colors = opt.fillColor || "#1f77b4";
        } else {
          opt.colors = colorPalette || ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
                                            "#8c564b", "e377c2", "#7f7f7f", "#bcbd22", "#17becf"];
        }

        opts.push(opt);
      }

      var l = L.minichart([opts[timeId].lat, opts[timeId].lng], opts[timeId]);

      // Keep a reference of colors and data for later use.
      l.opts = opts;
      l.colorPalette = colorPalette || ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
                                        "#8c564b", "e377c2", "#7f7f7f", "#bcbd22", "#17becf"];
      l.timeId = timeId;

      // Popups
      if (opts[timeId].popup) {
        l.bindPopup(opts[timeId].popup);
      }

      layerManager.addLayer(l, "minichart", opts[timeId].layerId);
    }
  };

  LeafletWidget.methods.updateMinicharts = function(options, data, maxValues, colorPalette, timeLabels, initialTime) {
    var i, j, k, t; // Variables used in loops

    var tslider = this.controls._controlsById.tslider;
    if (typeof timeLabels != "undefined") tslider.setTimeLabels(timeLabels);

    var timeId;
    if (typeof initialTime != "undefined" && initialTime !== null) {
      timeId = tslider.toTimeId(initialTime);
    } else {
      timeId = tslider.getTimeId();
    }
    tslider.setTimeId(timeId);

    for (i = 0; i < options.length; i++) {
      var l = this.layerManager.getLayer("minichart", options[i].layerId[timeId]);
      if (colorPalette) l.colorPalette = colorPalette;

      var opts = [];

      for (t = 0; t < options[i].layerId.length; t++) { // loop over time steps
        var opt = {};
        for (k in options[i]) {
          if (options[i].hasOwnProperty(k)) opt[k] = options[i][k][t];
        }

        if (data) {
          opt.data = data[i][t];
        } else {
          opt.data = l.opts[t].data;
        }

        if (opt.data.length == 1) opt.colors = opt.fillColor || l.opts[t].fillColor;
        else opt.colors = l.colorPalette;

        if (maxValues) opt.maxValues = maxValues;

        opts.push(opt);
      }
      l.opts = opts;
      l.setOptions(opts[timeId]);

      if (opts[timeId].popup) {
        l.bindPopup(opts[timeId].popup);
      }
    }

    if (typeof timeLabels != "undefined") {
      this.controls._controlsById.tslider.setTimeLabels(timeLabels);
    }
  };

  LeafletWidget.methods.removeMinicharts = function(layerId) {
    if (layerId.constructor != Array) layerId = [layerId];
    for (var i = 0; i < layerId.length; i++) {
      this.layerManager.removeLayer("minichart", layerId[i]);
    }
  };

  LeafletWidget.methods.clearMinicharts = function() {
    this.layerManager.clearLayers("minichart");
  };
}());

/*
- data: Array with one element per time id. Each element has one element per minichart
        that contains data for this minichart.

*/
