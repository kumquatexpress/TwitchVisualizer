var svg;
var width;
var height;
var CHANNELRADIUS = 10;
var USERRADIUS = 0.45;

$(document).ready(function(){

    width = $(window).innerWidth();
    height = $(window).height();

    svg = d3.select("#visualizer")
            .append("svg")
            .attr("width", width)
            .attr("height", height);
            
    $("circle").qtip({
        content: {
            text: $(this).attr("content")
        }
    });

    $("#channels").click(function(){
        var name = $("#search").val();
        var searchRoute = "search/"+name;
        searchThings(searchRoute, CHANNELRADIUS);
    });

    $("#users").click(function(){
        var name = $("#search").val();
        var searchRoute = "cosinesim/"+name;
        searchThings(searchRoute, USERRADIUS);
    });


});

function searchThings(route, radius){
        var dataset;
        var combs;

        $.ajax({
            url: route,
            type: "GET",
            dataType: "json",
            async: false,
        }).success(function(html){
            dataset = html["data"];
            names = html["names"];
            combs = html["combinations"];
        });
        svg.selectAll("circle").remove();

        var normalize = height*1.0/Math.max.apply(Math, dataset);

        var circles = svg.selectAll("circle")
                 .data(dataset)
                 .enter()
                 .append("circle");

        circles.attr("cx", function(d, i) {
            return Math.random()*Math.sqrt(d*normalize*radius)+(width/(dataset.length+1))*i;
        })
        .attr("cy", function(d){
            return randomHeight();
        })
        .attr("r", function(d) {
            return Math.sqrt(d*normalize)*radius;
        })
        .attr("fill", function(d){
            return randomColor();
        })
        .attr("style", "z-index:-1;")
        .attr("title", function(d, i){
            return names[i];
        });
}

function randomColor(){
    return '#'+Math.floor(Math.random()*11000215+4500000).toString(16);
}

function randomHeight(){
    return Math.random()*height;
}