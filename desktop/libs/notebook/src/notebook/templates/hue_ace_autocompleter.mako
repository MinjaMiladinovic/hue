## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

<%!
from django.utils.translation import ugettext as _
from desktop.views import _ko
%>

<%def name="hueAceAutocompleter()">
  <style>
    .hue-ace-autocompleter {
      position: fixed;
      display: flex;
      z-index: 1000;
      max-height: 250px;
      align-items: flex-start;
    }

    .autocompleter-suggestions {
      flex: 0 0 300px;
      z-index: 1002;
      display: flex;
      flex-direction: column;
      width: 300px;
      max-height: 250px;

      border: 1px solid #DDD;
      border-radius: 2px;
      background-color: #FFF;
      -webkit-box-shadow: 0 2px 8px rgba(0,0,0,.18);
      box-shadow: 0 2px 6px 0 rgba(0, 0, 0, 0.18), 0 2px 8px 0 rgba(0, 0, 0, 0.13);
    }

    .autocompleter-details {
      flex: 0 0 300px;
      z-index: 1001;
      display: flex;
      flex-direction: column;
      width: 300px;
      margin-left: 5px;
      max-height: 250px;

      border: 1px solid #DDD;
      border-radius: 2px;
      background-color: #FFF;
      -webkit-box-shadow: 0 2px 8px rgba(0,0,0,.18);
      box-shadow: 0 2px 6px 0 rgba(0, 0, 0, 0.18), 0 2px 8px 0 rgba(0, 0, 0, 0.13);
    }

    .autocompleter-header {
      flex: 0 0 20px;
      padding: 5px;
      background-color: #F9F9F9;
      line-height: 20px;
      font-size: 14px;
    }

    .autocompleter-list {
      flex: 0 0 300px;
      width: 300px;
      overflow-y: auto;
    }

    .autocompleter-list > div {
      height: 19px;
      clear: both;
      background-color: #FFF;
      padding:3px;
      cursor: pointer;
    }

    .autocompleter-list > div:hover {
      background-color: #DBE8F1;
    }

    .autocompleter-list > div.selected {
      background-color: #DBE8F1;
    }

    .autocompleter-spinner {
      position: relative;
      float: right;
      width: 15px;
      margin-top: 1px;
    }

    .autocompleter-entries {
      display: flex;
      position: relative;
      flex: 1 1 100%;
      overflow: hidden;
    }

    .autocompleter-categories {
      display: inline-block;
    }

    .autocompleter-categories > div {
      display: inline-block;
      border-bottom: 2px solid transparent;
      cursor: pointer;
      padding: 0 5px;
    }

    .autocompleter-categories > div.active {
      display: inline-block;
      border-bottom: 2px solid #338BB8;
      cursor: default;
    }

    .autocompleter-suggestion {
      display: flex;
      flex-direction: row;
      font: 12px/normal 'Monaco', 'Menlo', 'Ubuntu Mono', 'Consolas', 'source-code-pro', monospace;direction: ltr;
      line-height: 18px;
    }

    .autocompleter-suggestion-value {
      flex: 1 1 100%;
      margin-left: 3px;
      margin-right: 6px;
      overflow-x: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .autocompleter-suggestion-value b {
      text-shadow: 0 0 0.01em;
    }

    .autocompleter-suggestion-meta {
      flex: 1;
      color: #737373;
      white-space: nowrap;
      margin-right: 3px;
    }

    .autocompleter-dot {
      display: inline-block;
      margin-top: 5px;
      width: 8px;
      height: 8px;
      border-radius: 4px;
    }

    .popular-icon {
      color: #EDB233;
    }

    .autocompleter-details-contents {
      flex: 1 1 100%;
      overflow-y: auto;
      padding: 7px;
    }

    .autocompleter-details-contents .details-attribute,
    .autocompleter-details-contents .details-popularity {
      color: #737373;
      display: inline-block;
    }

    .autocompleter-details-contents .details-popularity .progress {
      display: inline-block;
      border-radius: 2px;
      height: 10px;
      width: 80px;
    }

    .autocompleter-details-contents .details-popularity .progress .bar {
      background-color: #338bb8;
    }

    .autocompleter-details-contents .details-comment {
      margin-top: 5px;
      color: #737373;
      font-style: italic;
    }

    .autocompleter-details-contents .details-code {
      background-color: #F9F9F9;
      padding:3px;
      color: #737373;
      font: 12px/normal 'Monaco', 'Menlo', 'Ubuntu Mono', 'Consolas', 'source-code-pro', monospace;direction: ltr;
    }

  </style>

  <script type="text/html" id="hue-ace-autocompleter">
    <!-- ko if: active -->
    <div class="hue-ace-autocompleter" data-bind="style: { top: top() + 'px', left: left() + 'px' }">
      <div class="autocompleter-suggestions">
        <!-- ko if: suggestions.availableCategories().length > 1 || suggestions.loading() -->
        <div class="autocompleter-header">
          <!-- ko if: suggestions.availableCategories().length > 1 -->
          <div class="autocompleter-categories" data-bind="foreach: suggestions.availableCategories()">
            <div data-bind="text: label, css: { 'active': $parent.suggestions.activeCategory() === $data }, style: { 'border-color': $parent.suggestions.activeCategory() === $data ? color : 'transparent' }, click: function (data, event) { $parent.suggestions.activeCategory($data); event.stopPropagation(); $parent.editor().focus(); }"></div>
          </div>
          <!-- /ko -->
          <div class="autocompleter-spinner"><!-- ko hueSpinner: { spin: suggestions.loading, size: 'small' } --><!-- /ko --></div>
        </div>
        <!-- /ko -->
        <div class="autocompleter-entries">
          <div class="autocompleter-list" data-bind="foreach: suggestions.filtered">
            <div class="autocompleter-suggestion" data-bind="click: function () { $parent.selectedIndex($index()); $parent.insertSuggestion(); $parent.editor().focus(); },
                css: { 'selected': $index() === $parent.selectedIndex() },
                event: { 'mouseover': function () { $parent.hoveredIndex($index()); }, 'mouseout': function () { $parent.hoveredIndex(null); } }">
              <div class="autocompleter-suggestion-value">
                <div class="autocompleter-dot" data-bind="style: { 'background-color': category.color }"></div> <span data-bind="matchedText: { suggestion: $data, filter: $parent.suggestions.filter }"></span>
              </div>
              <div class="autocompleter-suggestion-meta"><!-- ko if: typeof popular !== 'undefined' && popular --><i class="fa fa-star-o popular-icon"></i> <!-- /ko --><span data-bind="text: meta"></span></div>
            </div>
          </div>
        </div>
      </div>
      <!-- ko if: focusedEntry() && focusedEntry().details -->
      <!-- ko template: { name: 'autocomplete-details-' + focusedEntry().category.detailsTemplate, data: focusedEntry } --><!-- /ko -->
      <!-- /ko -->
    </div>
    <!-- /ko -->
  </script>

  <script type="text/html" id="autocomplete-details-keyword">
    <div class="autocompleter-details">
      <pre data-bind="text: ko.mapping.toJSON(details)"></pre>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-udf">
    <div class="autocompleter-details">
      <div class="autocompleter-header"><i class="fa fa-fw fa-superscript"></i> <span data-bind="text: details.signature.substring(0, details.signature.indexOf('('));"></span></div>
      <div class="autocompleter-details-contents">
        <div class="details-code" data-bind="text: details.signature"></div>
        <div class="details-comment" data-bind="text: details.description"></div>
      </div>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-database">
    <div class="autocompleter-details">
      <pre data-bind="text: ko.mapping.toJSON(details)"></pre>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-table">
    <div class="autocompleter-details">
      <div class="autocompleter-header"><i class="fa fa-fw" data-bind="css: { 'fa-eye': details.type.toLowerCase() !== 'table', 'fa-table': details.type.toLowerCase() === 'table' }"></i> <span data-bind="text: details.name"></span></div>
      <div class="autocompleter-details-contents">
        <div class="details-attribute" ><i class="fa fa-database fa-fw"></i> <span data-bind="text: details.database"></span></div>
        <!-- ko if: typeof details.popularity !== 'undefined' -->
        <div class="details-popularity margin-left-5" data-bind="tooltip: { title: '${ _ko('Popularity') } ' + details.popularity.relativePopularity + '%', placement: 'bottom' }"><i class="fa fa-fw fa-star-o popular-icon"></i>
          <div class="progress">
            <div class="bar" data-bind="style: { 'width': details.popularity.relativePopularity + '%' }"></div>
          </div>
        </div>
        <!-- /ko -->
        <!-- ko if: typeof details.comment !== 'undefined' && details.comment !== null -->
        <div class="details-comment" data-bind="text: details.comment"></div>
        <!-- /ko -->
      </div>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-column">
    <div class="autocompleter-details">
      <div class="autocompleter-header"><i class="fa fa-fw fa-columns"></i> <span data-bind="text: details.name"></span></div>
      <div class="autocompleter-details-contents">
        <div class="details-attribute" ><i class="fa fa-database fa-fw"></i> <span data-bind="text: details.database"></span></div>
        <div class="details-attribute" ><i class="fa fa-table fa-fw"></i> <span data-bind="text: details.table"></span></div>
        <!-- ko if: typeof details.popularity !== 'undefined' -->
        <br/>
        <div class="details-popularity margin-top-10" data-bind="tooltip: { title: '${ _ko('Popularity') } ' + details.popularity.relativePopularity + '%', placement: 'bottom' }"><i class="fa fa-fw fa-star-o popular-icon"></i>
          <div class="progress">
            <div class="bar" data-bind="style: { 'width': details.popularity.relativePopularity + '%' }"></div>
          </div>
        </div>
        <!-- /ko -->
        <!-- ko if: typeof details.comment !== 'undefined' && details.comment !== null -->
        <div class="details-comment" data-bind="text: details.comment"></div>
        <!-- /ko -->
      </div>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-variable">
    <div class="autocompleter-details">
      <pre data-bind="text: ko.mapping.toJSON(details)"></pre>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-hdfs">
    <div class="autocompleter-details">
      <div class="autocompleter-header"><i class="fa fa-fw" data-bind="css: { 'fa-folder-o': details.type === 'dir', 'fa-file-o': details.type !== 'dir' }"></i> <span data-bind="text: details.name"></span></div>
      <div class="autocompleter-details-contents" data-bind="template: { name: 'hdfs-details-content', data: { definition: details } }"><div>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-join">
    <div class="autocompleter-details">
      <div class="autocompleter-header"><i class="fa fa-fw fa-star-o"></i> ${ _('Popular join')}</div>
      <div class="autocompleter-details-contents">
        <div class="details-code" data-bind="text: value"></div>
        <div class="details-popularity margin-top-10" data-bind="tooltip: { title: '${ _ko('Popularity') } ' + details.relativePopularity + '%', placement: 'bottom' }"><i class="fa fa-fw fa-star-o popular-icon"></i>
          <div class="progress">
            <div class="bar" data-bind="style: { 'width': details.relativePopularity + '%' }"></div>
          </div>
        </div>
      </div>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-join-condition">
    <div class="autocompleter-details">
      <div class="autocompleter-header"><i class="fa fa-fw fa-star-o"></i> ${ _('Popular join condition')}</div>
      <div class="autocompleter-details-contents">
        <div class="details-code" data-bind="text: value"></div>
        <div class="details-popularity margin-top-10" data-bind="tooltip: { title: '${ _ko('Popularity') } ' + details.relativePopularity + '%', placement: 'bottom' }"><i class="fa fa-fw fa-star-o popular-icon"></i>
          <div class="progress">
            <div class="bar" data-bind="style: { 'width': details.relativePopularity + '%' }"></div>
          </div>
        </div>
      </div>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-agg-udf">
    <div class="autocompleter-details">
      <div class="autocompleter-header"><i class="fa fa-fw fa-superscript"></i> ${ _('Popular aggregate')} - <span data-bind="text: details.aggregateFunction"></span></div>
      <div class="autocompleter-details-contents">
        <div class="details-code" data-bind="text: value"></div>
        <div class="details-popularity margin-top-10" data-bind="tooltip: { title: '${ _ko('Popularity') } ' + details.relativePopularity + '%', placement: 'bottom' }"><i class="fa fa-fw fa-star-o popular-icon"></i>
          <div class="progress">
            <div class="bar" data-bind="style: { 'width': details.relativePopularity + '%' }"></div>
          </div>
        </div>
        <div class="details-comment" data-bind="text: details.function.description"></div>
      </div>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-value">
    <div class="autocompleter-details">
      <pre data-bind="text: ko.mapping.toJSON(details)"></pre>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-identifier">
    <div class="autocompleter-details">
      <pre data-bind="text: ko.mapping.toJSON(details)"></pre>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-cte">
    <div class="autocompleter-details">
      <pre data-bind="text: ko.mapping.toJSON(details)"></pre>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-group-by">
    <div class="autocompleter-details">
      <div class="autocompleter-header"><i class="fa fa-fw fa-star-o"></i> ${ _('Popular group by')}</div>
      <div class="autocompleter-details-contents">
        <div class="details-code" data-bind="text: value"></div>
        <div class="details-popularity margin-top-10" data-bind="tooltip: { title: '${ _ko('Workload percent') } ' + details.workloadPercent + '%', placement: 'bottom' }"><i class="fa fa-fw fa-star-o popular-icon"></i>
          <div class="progress">
            <div class="bar" data-bind="style: { 'width': details.workloadPercent + '%' }"></div>
          </div>
        </div>
      </div>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-order-by">
    <div class="autocompleter-details">
      <div class="autocompleter-header"><i class="fa fa-fw fa-star-o"></i> ${ _('Popular order by')}</div>
      <div class="autocompleter-details-contents">
        <div class="details-code" data-bind="text: value"></div>
        <div class="details-popularity margin-top-10" data-bind="tooltip: { title: '${ _ko('Workload percent') } ' + details.workloadPercent + '%', placement: 'bottom' }"><i class="fa fa-fw fa-star-o popular-icon"></i>
          <div class="progress">
            <div class="bar" data-bind="style: { 'width': details.workloadPercent + '%' }"></div>
          </div>
        </div>
      </div>
    </div>
  </script>

  <script type="text/html" id="autocomplete-details-filter">
    <div class="autocompleter-details">
      <div class="autocompleter-header"><i class="fa fa-fw fa-star-o"></i> ${ _('Popular filter')}</div>
      <div class="autocompleter-details-contents">
        <div class="details-code" data-bind="text: value"></div>
        <div class="details-popularity margin-top-10" data-bind="tooltip: { title: '${ _ko('Popularity') } ' + details.relativePopularity + '%', placement: 'bottom' }"><i class="fa fa-fw fa-star-o popular-icon"></i>
          <div class="progress">
            <div class="bar" data-bind="style: { 'width': details.relativePopularity + '%' }"></div>
          </div>
        </div>
      </div>
    </div>
  </script>


  <script type="text/javascript" charset="utf-8">
    (function () {

      var aceUtil = ace.require('ace/autocomplete/util');
      var HashHandler = ace.require('ace/keyboard/hash_handler').HashHandler;

      ko.bindingHandlers.matchedText = {
        init: function (element, valueAccessor) {
          var options = valueAccessor();
          var $element = $(element);

          var refresh = function () {
            $element.empty();
            var suggestion = options.suggestion;
            if (options.filter() && suggestion.matchIndex > -1) {
              var before = suggestion.value.substring(0, suggestion.matchIndex);
              var match = suggestion.value.substring(suggestion.matchIndex, suggestion.matchIndex + suggestion.matchLength);
              var after = suggestion.value.substring(suggestion.matchIndex + suggestion.matchLength);
              $element.append(document.createTextNode(before));
              $('<b>').text(match).appendTo($element);
              $element.append(document.createTextNode(after));
            } else {
              $element.text(suggestion.value);
            }
          };

          refresh();

          // matchIndex and matchLength are not observable, hence the pubsub to update
          var updatePubSub = huePubSub.subscribe('hue.ace.autocompleter.match.updated', refresh);
          ko.utils.domNodeDisposal.addDisposeCallback(element, updatePubSub.remove)
        }
      };

      function HueAceAutocompleter (params, element) {
        var self = this;
        self.editor = params.editor;
        self.snippet = params.snippet;

        self.autocompleter = new SqlAutocompleter3(params);
        self.suggestions = self.autocompleter.suggestions;

        self.active = ko.observable(false).extend({ rateLimit: 10 }); // to prevent flickering on empty result
        self.top = ko.observable(1);
        self.left = ko.observable(1);

        self.selectedIndex = ko.observable(0);
        self.hoveredIndex = ko.observable(null);

        self.focusedEntry = ko.pureComputed(function () {
          if (self.suggestions.filtered().length > 0) {
            return self.suggestions.filtered()[self.hoveredIndex() || self.selectedIndex()];
          }
          return null;
        });

        self.suggestions.filtered.subscribe(function (newValue) {
          if (self.selectedIndex() > newValue.length - 1) {
            self.selectedIndex(Math.max(0, newValue.length -1));
          }
        });

        self.keyboardHandler = new HashHandler();
        self.keyboardHandler.bindKeys({
          'Up': function() {
            if (self.selectedIndex() > 0) {
              self.selectedIndex(self.selectedIndex() - 1);
              self.scrollSelectionIntoView();
            }
          },
          'Down': function() {
            if (self.selectedIndex() < self.suggestions.filtered().length - 1) {
              self.selectedIndex(self.selectedIndex() + 1);
              self.scrollSelectionIntoView();
            }
          },
          'Ctrl-Up|Ctrl-Home': function() {
            self.selectedIndex(0);
            self.scrollSelectionIntoView();
          },
          'Ctrl-Down|Ctrl-End': function() {
            if (self.suggestions.filtered().length > 0 ) {
              self.selectedIndex(self.suggestions.filtered().length - 1);
              self.scrollSelectionIntoView();
            }
          },
          'Esc': function() {
            self.detach();
          },
          'Return': function() {
            self.insertSuggestion();
          },
          'Shift-Return': function() {
            // TODO: Delete suffix
            self.insertSuggestion();
          },
          'Tab': function() {
            self.insertSuggestion();
          }
        });

        var changeTimeout = -1;

        self.changeListener = function () {
          window.clearTimeout(changeTimeout);
          var cursor = self.editor().selection.lead;
          if (cursor.row != self.base.row || cursor.column < self.base.column) {
            self.detach();
          } else {
            changeTimeout = window.setTimeout(function () {
              self.suggestions.filter(self.editor().session.getTextRange({ start: self.base, end: self.editor().getCursorPosition() }));
              if (self.suggestions.filtered().length === 0) {
                self.detach();
              }
            }, 200);
          }
        };

        self.mousedownListener = function () {
          self.detach();
        };

        self.mousewheelListener = function () {
          self.detach();
        };

        var closeOnClickOutside = function (event) {
          if ($.contains(document, event.target) && !$.contains(element, event.target)) {
            self.detach();
          }
        };

        var positionInterval = -1;

        self.detach = function () {
          if (!self.active()) {
            return;
          }
          self.active(false);
          self.base.detach();
          self.base = null;
          window.clearTimeout(changeTimeout);
          window.clearInterval(positionInterval);
          $(document).off('click', closeOnClickOutside);
          self.editor().keyBinding.removeKeyboardHandler(self.keyboardHandler);
          self.editor().off('changeSelection', self.changeListener);
          self.editor().off('mousedown', self.mousedownListener);
          self.editor().off('mousewheel', self.mousewheelListener);
        };

        self.attach = function () {
          $(document).on('click', closeOnClickOutside);
          self.editor().keyBinding.addKeyboardHandler(self.keyboardHandler);
          self.editor().on('changeSelection', self.changeListener);
          self.editor().on('mousedown', self.mousedownListener);
          self.editor().on('mousewheel', self.mousewheelListener);
          var $container = $(self.editor().container);
          var initialOffset = $(self.editor().container).offset();
          positionInterval = window.setInterval(function () {
            var newOffset = $container.offset();
            if (newOffset.top !== initialOffset.top || newOffset.left !== initialOffset.left) {
              self.detach();
            }
          }, 300);
        };

        huePubSub.subscribe('hue.ace.autocompleter.done', function () {
          window.setTimeout(function () {
            if (self.active() && self.suggestions.filtered().length === 0) {
              self.detach();
            }
          }, 0);
        });

        huePubSub.subscribe('hue.ace.autocompleter.show', function (data) {
          var session = self.editor().getSession();
          var pos = self.editor().getCursorPosition();
          var line = session.getLine(pos.row);
          var prefix = aceUtil.retrievePrecedingIdentifier(line, pos.column);
          var newBase = session.doc.createAnchor(pos.row, pos.column - prefix.length);
          self.top(data.position.top + data.lineHeight + 3);
          self.left(data.position.left);
          if (!self.active() || (!self.base || newBase.column !== self.base.column || newBase.row !== self.base.row)) {
            self.autocompleter.autocomplete();
          }
          newBase.$insertRight = true;
          self.base = newBase;
          self.suggestions.filter(prefix);
          self.active(true);
          self.attach();
          self.selectedIndex(0);
        });

        huePubSub.subscribe('hue.ace.autocompleter.hide', function () {
          self.detach();
        });

      }

      HueAceAutocompleter.prototype.insertSuggestion = function () {
        var self = this;
        if (self.suggestions.filtered().length === 0) {
          self.detach();
          return;
        }
        if (self.suggestions.filter()) {
          var ranges = self.editor().selection.getAllRanges();
          for (var i = 0, range; range = ranges[i]; i++) {
            range.start.column -= self.suggestions.filter().length;
            self.editor().session.remove(range);
          }
        }
        self.editor().execCommand('insertstring', self.suggestions.filtered()[self.selectedIndex()].value);
        self.editor().renderer.scrollCursorIntoView();
        self.detach();
      };

      HueAceAutocompleter.prototype.scrollSelectionIntoView = function () {
        var self = this;
        var $autocompleterList = $('.autocompleter-list');
        var selected = $autocompleterList.children().eq(self.selectedIndex());
        var selectedTop = selected.position().top;
        if (selectedTop < 0) {
          $autocompleterList.scrollTop($autocompleterList.scrollTop() + selectedTop);
          return;
        }
        var selectedHeight = selected.outerHeight(true);
        var listHeight = $autocompleterList.innerHeight();

        var diff = (selectedHeight + selectedTop) - listHeight;
        if (diff > 0) {
          $autocompleterList.scrollTop($autocompleterList.scrollTop() + diff);
        }
      };

      ko.components.register('hueAceAutocompleter', {
        viewModel: { createViewModel: function (params, componentInfo) {
          return new HueAceAutocompleter(params, componentInfo.element);
        }},
        template: { element: 'hue-ace-autocompleter' }
      });
    })();
  </script>
</%def>
