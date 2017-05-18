(function() {
  'use strict';

  module.exports.initTimeSlider = initTimeSlider;
  module.exports.processOptions = processOptions;
  module.exports.addSetTimeIdMethod = addSetTimeIdMethod;
  module.exports.addRemoveMethods = addRemoveMethods;
  module.exports.getInitOptions = getInitOptions;
  module.exports.defaultPopup = defaultPopup;

  // Add a time slider if it does not already exist
  function initTimeSlider(leafletInstance, timeLabels, initialTime) {
    var tslider;

    if (!leafletInstance.controls._controlsById.tslider) {
      tslider = L.timeSlider({
        timeLabels: timeLabels,
        onTimeIdChange: function(timeId) {
          var types = ["minichart", "flow"];
          for (var i = 0; i < types.length; i++) {
            var layers = leafletInstance.layerManager._byCategory[types[i]];
            for (var k in layers) {
              if (layers[k]) layers[k].setTimeId(timeId);
            }
          }
        }
      });
      leafletInstance.controls.add(tslider, "tslider");
    } else {
      tslider = leafletInstance.controls._controlsById.tslider;
      if (typeof timeLabels != "undefined") tslider.setTimeLabels(timeLabels);
    }

    var timeId;
    if (typeof initialTime != "undefined" && initialTime !== null) {
      timeId = tslider.toTimeId(initialTime);
    } else {
      timeId = tslider.getTimeId();
    }
    tslider.setTimeId(timeId);

    return timeId;
  }

  /* Convert options sent by R in a useful format for the javascript code.
     Args:
     - options: object sent by R
     - callback: function(opts, i) with 'opts' the options for a given layer
                 and 'i' the index of the given layer
   */
  function processOptions(options, callback) {
    for (var i = 0; i < options.length; i++) {
      var opts = [];
      var timesteps = getNumberOfTimesteps(options);

      for (var t = 0; t < timesteps; t++) {
        var opt = {};
        for (var k in options[i].dyn) {
          if (options[i].dyn.hasOwnProperty(k)) {
            opt[k] = options[i].dyn[k][t];
          }
        }

        opts.push(opt);
      }

      callback(opts, i, options[i].static);
    }
  }

  function getNumberOfTimesteps(options) {
    return options[0].timeSteps;
  }

  function getInitOptions(opts, staticOpts, timeId) {
    var opt = opts[timeId];
    for (var k in opt) {
      if (opt.hasOwnProperty(k)) {
        staticOpts[k] = opt[k];
      }
    }
    return staticOpts;
  }

  // Add to a leaflet class the method "setTimeId" to update a layer when timeId
  // changes.
  function addSetTimeIdMethod(className, updateFunName) {
    if (!L[className].prototype.setTimeId) {
      L[className].prototype.setTimeId = function(timeId) {
        if (timeId == this.timeId) return;

        if (typeof this.opts !== "undefined" && typeof this.opts[timeId] !== 'undefined') {
          var opt = this.opts[timeId];
          this[updateFunName](opt);
          if (opt.popup) {
            this.bindPopup(opt.popup);
          } else {
            this.bindPopup(defaultPopup(this.layerId, this.opts[timeId].data, this.opts[timeId].popupData, this.popupLabels))
          }
        }
        this.timeId = timeId;
      };
    }
  }

  function addRemoveMethods(className, groupName) {
    LeafletWidget.methods["remove" + className + "s"] = function(layerId) {
      if (layerId.constructor != Array) layerId = [layerId];
      for (var i = 0; i < layerId.length; i++) {
        this.layerManager.removeLayer(groupName, layerId[i]);
      }
    };

    LeafletWidget.methods["clear" + className + "s"] = function() {
      this.layerManager.clearLayers(groupName);
    };
  }

  function defaultPopup(title, values, supValues, keys) {
    if (title) title = "<h2>" + title + "</h2>";
    else title = "";
    var content = "";
    if (values) {

      if (supValues) values = values.concat(supValues);

      if (keys && keys.length > 0) {
        var rows = [];
        for (var i = 0; i < values.length; i++) {
          var row = "";
          row += "<td class='key'>" + keys[i] + "</td>";
          row += "<td class='value'>" + values[i] + "</td>";
          row = "<tr>" + row + "</tr>";
          rows.push(row);
        }
        content = rows.join("");
        content = '<table><tbody>' + content +'</tbody></table>';
      } else {
        content = values.join(", ");
      }
    }

    return '<div class="popup">'+ title + content + '</div>'
  }
}());
