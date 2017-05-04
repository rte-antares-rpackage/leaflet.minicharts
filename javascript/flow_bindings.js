(function() {
  'use strict';

  var utils = require("./utils");
  /*
  Add a segment on the map with a triangle in the middle representing its direction.

  @param data:
    data.frame with columns x0, y0, x1, y1 and optionnaly dir, color, opacity, weight
    popup and layerId

  */
  LeafletWidget.methods.addFlows = function(data, timeLabels, initialTime) {
    var self = this;

    // Initialize time slider
    var timeId = utils.initTimeSlider(this, timeLabels, initialTime);

    // Add method to update time
    utils.addSetTimeIdMethod("Flow", "setStyle");

    // Create flows
    utils.processOptions(data, function(opts, i) {
      var l = L.flow(
        [opts[timeId].lat0, opts[timeId].lng0],
        [opts[timeId].lat1, opts[timeId].lng1],
        opts[timeId]
      );
      l.opts = opts;
      l.timeId = timeId;

      if (opts[timeId].popup) l.bindPopup(opts[timeId].popup);

      self.layerManager.addLayer(l, "flow", opts[timeId].layerId);
    });
  };

  /*
  Update the style of directed segments

  @param data
    data.frame with columns layerId and optionnaly dir, color, opacity popup
    and weight

  */
  LeafletWidget.methods.updateFlows = function(data, timeLabels, initialTime) {
    var self = this;

    var timeId = utils.initTimeSlider(this, timeLabels, initialTime);

    utils.processOptions(data, function(opts, i) {
      var l = self.layerManager.getLayer("flow", opts[timeId].layerId);
      l.setStyle(opts[timeId]);
      l.opts = opts;
      l.timeId = timeId;

      if (opts[timeId].popup) l.bindPopup(opts[timeId].popup);
    });
  };

  utils.addRemoveMethods("Minichart", "minichart");
}());
