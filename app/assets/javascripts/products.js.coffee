# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  Morris.Line
    element: 'products_chart'
    data: $('#products_chart').data('products')
    xkey: 'released_on'
    ykeys: ['price']
    labels: ['Total Price']
    preUnits: '$'
