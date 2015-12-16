Ext.define 'FM.view.charts.FileSizeChart',
  extend: 'Ext.chart.Chart'
  alias: 'widget.file-size-chart'
  cls: 'fm-file-size-chart'
  animate: true
  shadow: false
  requires: [
    'Ext.chart.series.Pie'
    'FM.model.File'
  ]
  series: [
    {
      type: 'pie'
      showInLegend: false
      field: 'size'
      donut: 40
      highlight:
        segment:
          margin: 10
      label:
        field: 'name'
        display: 'outside'
        calloutLine: true
    }
  ]
  defaults:
    flex: 1
  minHeight: 320
  insetPadding: 50
  store:
    sorters:
      property: 'size'
      direction: 'DESC'
    model: 'FM.model.File'
  initComponent: () ->
    FM.Logger.log('FM.view.charts.FileSizeChart init')
    @callParent(arguments)

  setChartData: (filelist) ->
    FM.Logger.log("setChartData in FileSizeChart called ", filelist)
    @store.loadData(filelist)