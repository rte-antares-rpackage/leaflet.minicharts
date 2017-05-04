(function() {
  'use strict';

  /*
  Add a segment on the map with a triangle in the middle representing its direction.

  @param data:
    data.frame with columns x0, y0, x1, y1 and optionnaly dir, color, opacity, weight
    popup and layerId

  */
  LeafletWidget.methods.addFlows = function(data, timeLabels, initialTime) {
    var layerManager = this.layerManager;
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
    if (!L.Flow.prototype.setTimeId) {
      L.Flow.prototype.setTimeId = function(timeId) {
        if (timeId == this.timeId) return;

        if (typeof this.opts !== "undefined" && typeof this.opts[timeId] !== 'undefined') {
          var opt = this.opts[timeId];
          this.setStyle(opt);
          if (opt.popup) {
            this.bindPopup(opt.popup);
          }
        }
        this.timeId = timeId;
      };
    }

    for (var i = 0; i < data.length; i++) {
      var opts = [];

      for (var t = 0; t < data[i].layerId.length; t++) {
        var opt = {};
        for (var k in data[i]) {
          if (data[i].hasOwnProperty(k)) {
            opt[k] = data[i][k][t];
          }
        }

        opts.push(opt);
      }

      var l = L.flow(
        [opts[timeId].y0, opts[timeId].x0],
        [opts[timeId].y1, opts[timeId].x1],
        opts[timeId]
      );
      l.opts = opts;
      l.timeId = timeId;

      if (opts[timeId].popup) l.bindPopup(opts[timeId].popup);

      this.layerManager.addLayer(l, "flow", opts[timeId].layerId);
    }
  };

  /*
  Update the style of directed segments

  @param data
    data.frame with columns layerId and optionnaly dir, color, opacity popup
    and weight

  */
  LeafletWidget.methods.updateFlows = function(data, timeLabels, initialTime) {
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

    for (i = 0; i < data.length; i++) {
      var opts = [];

      for (t = 0; t < data[i].layerId.length; t++) {
        var opt = {};
        for (var k in data[i]) {
          if (data[i].hasOwnProperty(k)) {
            opt[k] = data[i][k][t];
          }
        }

        opts.push(opt);
      }

      var l = this.layerManager.getLayer("flow", opts[timeId].layerId);
      l.setStyle(opts[timeId]);
      l.opts = opts;
      l.timeId = timeId;

      if (opts[timeId].popup) l.bindPopup(opts[timeId].popup);
    }
  };

  LeafletWidget.methods.removeFlows = function(layerId) {
    if (layerId.constructor != Array) layerId = [layerId];
    for (var i = 0; i < layerId.length; i++) {
      this.layerManager.removeLayer("flow", layerId[i]);
    }
  };

  LeafletWidget.methods.clearFlows = function() {
    this.layerManager.clearLayers("flow");
  };
}());
