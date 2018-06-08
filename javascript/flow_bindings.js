(function() {
  'use strict';

  var utils = require("./utils");
  /*
  Add a segment on the map with a triangle in the middle representing its direction.

  @param data:
    data.frame with columns x0, y0, x1, y1 and optionnaly dir, color, opacity, weight
    popup and layerId

  */
  LeafletWidget.methods.addFlows = function(options, timeLabels, initialTime, popupArgs) {
    var self = this;

    // Initialize time slider
    var timeId = utils.initTimeSlider(this, timeLabels, initialTime);

    // Add method to update time
    utils.addSetTimeIdMethod("Flow", "setStyle");

    // Create flows
    utils.processOptions(options, function(opts, i, staticOpts) {
      for (var t = 0; t < opts.length; t++) {
        if (typeof opts[t].value != "undefined") opts[t].data = [opts[t].value];
        else if (typeof staticOpts.value != "undefined") opts[t].data = [staticOpts.value];

        if(popupArgs && popupArgs.supValues) {
          opts[t].popupData = popupArgs.supValues[i][t];
        }
        if(popupArgs && popupArgs.html) {
          opts[t].popupHTML = popupArgs.html[i][t];
        }
      }

      var l = L.flow(
        [staticOpts.lat0, staticOpts.lng0],
        [staticOpts.lat1, staticOpts.lng1],
        utils.getInitOptions(opts, staticOpts, timeId)
      );
      l.opts = opts;
      l.timeId = timeId;
      if (staticOpts.layerId.indexOf("_flow") != 0) l.layerId = staticOpts.layerId;
      l.popupArgs = popupArgs;

      utils.setPopup(l, timeId);
      self.layerManager.addLayer(l, "flow", staticOpts.layerId);
    });
  };

  /*
  Update the style of directed segments

  @param data
    data.frame with columns layerId and optionnaly dir, color, opacity popup
    and weight

  */
  LeafletWidget.methods.updateFlows = function(options, timeLabels, initialTime, popupArgs) {
    var self = this;

    var timeId = utils.initTimeSlider(this, timeLabels, initialTime);

    utils.processOptions(options, function(opts, i, staticOpts) {
      var l = self.layerManager.getLayer("flow", staticOpts.layerId);
      if (!l) return;

      if (popupArgs) l.popupArgs = popupArgs;

      for (var t = 0; t < opts.length; t++) {
        if (typeof opts[t].value != "undefined") opts[t].data = [opts[t].value];
        else if (typeof staticOpts.value != "undefined") opts[t].data = [staticOpts.value];
        else if (l.opts[t]) opts[t].data = l.opts[t].data

        if(popupArgs && popupArgs.supValues) {
          opts[t].popupData = popupArgs.supValues[i][t];
        } else {
          if (l.opts[t]) opts[t].popupData = l.opts[t].popupData;
        }
        if(popupArgs && popupArgs.html) {
          opts[t].popupHTML = popupArgs.html[i][t];
        } else {
          if (l.opts[t]) opts[t].popupHTML = l.opts[t].popupHTML;
        }
      }

      l.setStyle(utils.getInitOptions(opts, staticOpts, timeId));
      l.opts = opts;
      l.timeId = timeId;

      utils.setPopup(l, timeId);
    });
  };

  utils.addRemoveMethods("Flow", "flow");
}());
