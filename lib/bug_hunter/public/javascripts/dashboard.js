$(document).ready(function() {
    setTimeout(function() {
        window.location.reload();
    }, 30000);

    var charts = $(".widget .chart");

    $.each(charts, function() {
        var chart = $(this);
        var x = eval(chart.attr("data-points-x"));
        var y = eval(chart.attr("data-points-y"));
        var labels = eval(chart.attr("data-labels"));

        var width = y.length * 35;
        chart.attr("style", "width: "+(width+40)+"px;");

        raphael = Raphael(chart.attr("id"));

        switch(chart.attr("data-display")) {
            case 'bar': {
                var fin = function () {
                    var text = labels[this.bar.id] + "("+ this.bar.value +")";
                    this.flag = raphael.popup(this.bar.x, this.bar.y, text).insertBefore(this);
                }
                var fout = function () {
                    this.flag.animate({opacity: 0}, 300, function () {this.remove();});
                }
                raphael.barchart(10, 10, 300, 220, [y]).hover(fin, fout);
            }
            break;
            case 'line': {
                var chart = raphael.linechart(
                    30, 0, width-100, 300,
                    [x],
                    [y],
                    {
                        nostroke: false,
                        axis: "0 0 1 1",
                        symbol: "circle",
                        smooth: false
                    }
                ).hoverColumn(function () {
                    this.tags = raphael.set();

                    for (var i = 0, ii = this.y.length; i < ii; i++) {
                        var text = labels[i] + "(" + this.values[i]+")";
                        var tag = raphael.tag(this.x, this.y[i], text, 0, 5)
                        tag.insertBefore(this);
                        tag.attr([
                            { fill: "#fff" },
                            { fill: this.symbols[i].attr("fill") }
                        ]);
                        this.tags.push(tag);
                    }
                }, function () {
                    this.tags && this.tags.remove();
                });

                var axisItems = chart.axis[0].text.items
                for( var i = 0; i < axisItems.length; i++ ) {
                    axisItems[i].attr("text", "");
                    axisItems[i].attr("fill", "#FFF");
                }

                chart.axis[0].attr("stroke", "#FFF");
                chart.axis[1].attr("stroke", "#FFF");
            }
            break;
            case 'pie': {
                var pie = raphael.piechart(300, 120, 80, y, {
                    legend: labels,
                    legendcolor: '#fff',
                    strokewidth: 0.7,
                    legendpos: "west"
                });
            }
            break;
        }

    });
})