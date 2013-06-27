#!/usr/bin/python
import sys, os

def usage():
    print("%s " % sys.argv[0] )


from string import Template
HTML_TEMPLATE = Template(
'''<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
 <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>Interactive Graphs (Flot)</title>
    <link href="http://zhanxw.com/flot/layout.css" rel="stylesheet" type="text/css">
    <!--[if lte IE 8]><script language="javascript" type="text/javascript" src="../excanvas.min.js"></script><![endif]-->
    <script language="javascript" type="text/javascript" src="http://zhanxw-anno.appspot.com/static/jquery.min.js"></script>
    <script language="javascript" type="text/javascript" src="http://zhanxw-anno.appspot.com/static/jquery.flot.min.js"></script>
    <script language="javascript" type="text/javascript" src="http://zhanxw-anno.appspot.com/static/jquery.flot.navigate.min.js"></script>
    <style type="text/css" media="screen">
    html {
      padding: 0px;
      margin: 0px;
      }
    body {
      background-color: #e1ddd9;
      font-size: 12px;
      font-family: Verdana, Arial, SunSans-Regular, Sans-Serif;
      color:#564b47;
      padding:0px 20px;
      margin:0px;
      }
    #container {
      width: 1000px;
      margin-bottom: 10px;
      margin-left: auto;
      margin-right: auto;
      /*background-color: #ff99cc;*/
    }
	    /*  positioning-layers dynamisch */
    #menu {
      float: left;
      width: 350px;
      margin: 0px;
      padding: 0px;
      }
    #content {
      background-color: #ffffff;
      padding: 0px;
      margin-left: 350px;
      margin-right: 0px;
    }
    div#content {
      min-height:600px;
      padding-left: 25px;
      height:expression(this.scrollHeight > 600 ? "auto":"600px");
    }
    </style>
 </head>
    <body>
    <div id="container">
    <div id="menu">
${HTML_BUTTON}

	<!--  <p> <input class = "drawGraph1" type = "button" value = "Graph1"> </p>   -->
	<!--  <p> <input class = "drawGraph2" type = "button" value = "Graph2"> </p>   -->
    </div>
    <div id="content">
      <h1 id="graphTitle"> Title </h1>
      <p> <div style="float:left"> x-axis: </div> <div id="graphXlab" style="float:left"> xlab </div></p>
      <br/>
      <p> <div style="float:left"> y-axis: </div> <div id="graphYlab" style="float:left"> ylab </div></p>
      <br/>
      <br/>
      <div id="placeholder" style="width:600px;height:600px;"></div>
      <div id="legend" style="float:left"></div>
    </div>
    </div>
<script type="text/javascript">

${FUNCTION_FOR_EACH_PLOT}

    //////function f1() {
    //////    var s1 = [[0, 3], [8, 5], [9, 13]];
    //////
    //////    // a null signifies separate line segments
    //////    var s2 = [[0, 12], [7, 12], null, [7, 2.5], [12, 2.5]];
    //////    $("#graphTitle").text("A1");
    //////    $("#graphXlab").text("x1");
    //////    $("#graphYlab").text("y1");
    //////    $.plot($("#placeholder"), [ s1, s2 ],
    //////               {
    //////               series: {
    //////                   lines: { show: true },
    //////                   points: { show: true }
    //////               },
    //////                       grid: { hoverable: true, clickable: true }
    //////            }
    //////          );
    //////};

${FUNCTION_FOR_CLICK_BUTTON}
    //////    $("input.drawGraph1").click(function() {
    //////        f1(); 
    //////    });


    function showTooltip(x, y, contents) {
        $(\'<div id="tooltip">\' + contents + \'</div>\').css( {
            position: "absolute",
            display: "none",
            top: y + 5,
            left: x + 5,
            border: "1px solid #fdd",
            padding: "2px",
            "background-color": "#fee",
            opacity: 0.80
        }).appendTo("body").fadeIn(200);
    }



    var previousPoint = null;
    $("#placeholder").bind("plothover", function (event, pos, item) {
        $("#x").text(pos.x.toFixed(2));
        $("#y").text(pos.y.toFixed(2));

        if (item) {
            if (previousPoint != item.dataIndex) {
                previousPoint = item.dataIndex;
                
                $("#tooltip").remove();
                var x = item.datapoint[0].toFixed(2),
                    y = item.datapoint[1].toFixed(2);
                
                showTooltip(item.pageX, item.pageY,
                            item.series.label + " of " + x + " = " + y);
            }
        }
        else {
            $("#tooltip").remove();
            previousPoint = null;            
        }
    });
</script>

 </body>
</html>''')

Template_HTML_BUTTON = Template(
'''
	<input class = "${buttonClass}" type = "button" value = "${buttonText}" style="border: 1px solid #006;background: #ccf;padding: 1px; margin: 2px;"> <br />
''')

Template_FUNCTION_FOR_EACH_PLOT = Template(
'''
    function ${plotFunctionName}() {
        ${dataDefine}
        $("#graphTitle").text("${main}");
        $("#graphXlab").text("${xlab}");
        $("#graphYlab").text("${ylab}");
        $.plot($("#placeholder"),
	       [ ${dataName} ],
               {
	         series: {
                   lines: { show: true },
                   points: { show: true }
                 },
		 legend: {show:true, container:"#legend"},
                 grid: { hoverable: true, clickable: true },
		 xaxis: { min: ${xaxis_min}, max: ${xaxis_max} },
		 yaxis: { min: ${yaxis_min}, max: ${yaxis_max} },
		 zoom: { interactive: true },
		 pan: { interactive: true }
               }
              );
    };
''')

Template_FUNCTION_FOR_CLICK_BUTTON = Template(
'''
    $("input.${buttonClass}").click(function() {
        ${plotFunctionName}(); 
    });
''')

def isFloat(x):
    try:
	float(x)
	return True
    except:
	return False

def getText(x):
    rc = []
    for node in x:
	if node.nodeType == node.TEXT_NODE:
	    rc.append(node.data)
    return ''.join(rc)

def outputPlot(idx, g):
    p = {'buttonClass': 'buttonClass%04d' % idx,
	 'buttonText' : 'buttonText%04d' % idx,
	 'plotFunctionName': 'plotFunction%04d' %idx,
	 'main': 'DefaultTitle',
	 'xlab': 'X',
	 'ylab': 'Y',
	 'xaxis_min': 'null',
	 'xaxis_max': 'null',
	 'yaxis_min': 'null',
	 'yaxis_max': 'null',
	 'data': []
	 }
    
    xmlTitle = g.getElementsByTagName('title')[0]
    titleText = getText(xmlTitle.childNodes)
    #print "Title: ", titleText
    p['main'] = titleText
    if len(titleText) > 0:
	p['buttonText'] = titleText
    
    xmlXaxis = g.getElementsByTagName('xaxis')[0]
    xaxisText = getText(xmlXaxis.childNodes)
    #print "Xaxis: ", xaxisText
    p['xlab'] = xaxisText
    # print xmlXaxis
    # print dir(xmlXaxis)
    if xmlXaxis.hasAttribute('min'):
    	p['xaxis_min'] = xmlXaxis.getAttribute('min')
    if xmlXaxis.hasAttribute('max'):
    	p['xaxis_max'] = xmlXaxis.getAttribute('max')
    
    xmlYaxis = g.getElementsByTagName('yaxis')[0]
    yaxisText = getText(xmlYaxis.childNodes)
    #print "Yaxis: ", yaxisText
    p['ylab'] = yaxisText
    if xmlYaxis.hasAttribute('min'):
    	p['yaxis_min'] = xmlYaxis.getAttribute('min')
    if xmlYaxis.hasAttribute('max'):
    	p['yaxis_max'] = xmlYaxis.getAttribute('max')

    
    xmlDataList = g.getElementsByTagName('series')
    for xmlData in xmlDataList:
	d = dict()
	
	# label
	label = xmlData.getAttribute('label')
	#print "Label:", label
	# x
	x = getText(xmlData.getElementsByTagName('x')[0].childNodes)
	#print "X: ", x
	# y
    	y = getText(xmlData.getElementsByTagName('y')[0].childNodes)
	#print "Y: ", y

	d['label'] = label
	d['x'] = x
	d['y'] = y
	p['data'].append(d)

    # convert p['data'] to p['dataDefine'] and p['dataName']
    dataDefine = ''
    dataName = []
    import json
    for i, v in enumerate(p['data']):
	valName = 's%04d' % i
	x = v['x'].split(',')
	y = v['y'].split(',')
	if len(x) != len(y):
	    print >>sys.stderr, "inconsistent x and y: ", x, '\n', y
	l = min(len(x), len(y))
	xy = [ (float(x[i]), float(y[i]) ) for i in xrange(l) if (isFloat(x[i]) and isFloat(y[i])) ]
	dataDefine += 'var %s =  %s;' % (valName, json.dumps(xy))
	dataName.append( '{data: %s, label: "%s"}' % (valName, v['label']) )
    dataName = ','.join(dataName)
    p['dataName'] = dataName
    p['dataDefine'] = dataDefine
    return p

if __name__ == '__main__':
    from xml.dom.minidom import parse
    dom = parse(sys.argv[1])

    htmlButton = []
    jsButtonOnClick = []
    jsPlot = []

    for graph in dom.getElementsByTagName('graph'):
	#print graph
	plotList = graph.getElementsByTagName('plot')
	for idx, plot in enumerate(plotList):
	    #print i
	    p = outputPlot(idx, plot)
	    #print p

	    htmlButton.append(Template_HTML_BUTTON.safe_substitute(p))
	    jsButtonOnClick.append(Template_FUNCTION_FOR_CLICK_BUTTON.safe_substitute(p))
	    jsPlot.append(Template_FUNCTION_FOR_EACH_PLOT.safe_substitute(p))

    print HTML_TEMPLATE.safe_substitute(HTML_BUTTON = '\n'.join(htmlButton),
					FUNCTION_FOR_EACH_PLOT = '\n'.join(jsPlot),
					FUNCTION_FOR_CLICK_BUTTON = '\n'.join(jsButtonOnClick))
	
    
