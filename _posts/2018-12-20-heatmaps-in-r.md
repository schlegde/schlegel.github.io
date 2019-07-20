---
layout: post
title: "Creating a heat map from coordinates using R"
date:   2018-12-20 18:21:22
description: ""
category:
tags: ["Data Visualization", "Data Analysis", "R", "McDonalds", "Maps"]
---

<img src="https://www.dropbox.com/s/5bt8fohfknenrnl/header.png?raw=1" alt="preview_picture" />

Recently we wanted to visualise some coordinates which are tracked during a specific API call. The goal was helping us to find out if the functionality is used at all and especially __where__ it is used. It might not be a good use of your time to improve a service in Antartica if no one there is trying to use it. Don't worry, thee is no connection between the user and the location.

Wouldn't it be cool to view that data quickly via [heat map](https://en.wikipedia.org/wiki/Heat_map)?

Remembering [R](https://en.wikipedia.org/wiki/R_(programming_language)), an environment for statistical computing and graphics, from a past project, we quickly had enough keywords to google for.

A good starting point, although with a sad topic, can be found [here](https://trucvietle.me/r/tutorial/2017/01/18/spatial-heat-map-plotting-using-r.html). Let's find a dataset for the following example.

### Finding sample data to work with

Your actual data might be located in some database. Feel free to use is as the input. But for the sake of having some unrelated data for this post I'm taking all locations of [McDonald's](https://en.wikipedia.org/wiki/McDonald%27s) in Germany. No affiliation whatsoever to the company 😉. These locations can be found using their [german restaurant finder](http://www.mcdonalds.de/restaurant-suche). Simly increase the radius of the search area.

{% highlight bash %}
curl -X POST http://www.mcdonalds.de/search\?longitude\=9.481544\&latitude\=51.312801\&radius\=1000 > response.json
{% endhighlight %}

The location is the coordinates of Kassel, which is close to the center of Germany. A radius of 1000km covers the whole country.

We transform the `reponse.json` into [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) via

{% highlight bash %}
< response.json | jq '.restaurantList[].restaurant | [.latitude,.longitude] | @csv' | tr -d '"' > locations.csv
{% endhighlight %}

We will work on the file `locations.csv`. We provide some headers for the columns adding the first line `Latitude,Longitude`

The first four lines of the CSV thus look like

{% highlight csv %}
Latitude,Longitude
48.5600147488,12.1366223689
48.5390797532,12.0959665032
53.3636784825,9.8725737345
{% endhighlight %}

Now we need to put these coordinates on a map. Since [Google maps](https://cloud.google.com/maps-platform) started to require an API key why not try out another provider?

In the example we are using [stamen](http://maps.stamen.com/), which offers map visualisations using OpenStreetMap data. No API required. Yet.

Setup instructions can be found on [GitHub](https://github.com/axelhodler/heator/blob/master/README.md). We start with some dependencies of R.

{% highlight r %}
library(ggplot2)
library(ggmap)
library(RColorBrewer)
{% endhighlight %}

[ggplot2](https://ggplot2.tidyverse.org/) for graphics. [ggmap](https://github.com/dkahle/ggmap) for plotting maps and [RColorBrewer](https://cran.r-project.org/web/packages/RColorBrewer/index.html) provides colour palettes for data visualisation.The red to yellow to blue for the heat map in our case.

First we read the contents of our `locations.csv`

{% highlight r %}
coords.data <- read.csv(file="./locations.csv")
{% endhighlight %}

Then we define the bounds of the to be mapped country. Germany in our case.

{% highlight r %}
map_bounds <- c(left = 5, bottom = 47, right = 16, top = 56)
{% endhighlight %}

We configure the map, bounds, zoom and style, via

{% highlight r %}
coords.map <- get_stamenmap(map_bounds, zoom = 7, maptype = "toner-lite")
{% endhighlight %}

To next adding the logic for rendering the heat map

{% highlight r %}
coords.map <- ggmap(coords.map, extent="device", legend="none")

coords.map <- coords.map + stat_density2d(data=coords.data,  aes(x=Longitude, y=Latitude, fill=..level.., alpha=..level..), geom="polygon")

coords.map <- coords.map + scale_fill_gradientn(colours=rev(brewer.pal(7, "Spectral")))
{% endhighlight %}

And get the output as an image

{% highlight r %}
coords.map <- coords.map + theme_bw()

ggsave(filename="./coords.png")
{% endhighlight %}

Now we invoke the script via `Rscript script.R` and are presented with the following

<img src="https://www.dropbox.com/s/km7vm7d7csldagq/mid.png?raw=1" alt="heatmap" />

Nice. Let's add the actual locations to the map to see how these heat spots were created. Add the next snipped before creating the output via `ggsave`.

```
coords.map <- coords.map + geom_point(data=coords.data, aes(x=Longitude, y=Latitude), fill="red", shape=23, alpha=0.8)
```

Running the script again yields

<img src="https://www.dropbox.com/s/qv6sf7sg1fxsb43/last.png?raw=1" alt="heatmap_with_markers" />

Of course, for a company like McDonald's, this closely resembles the population centers in Germany. But if you are creating an App which is offering surf spots or hiking trails the map might look quite different.

The code with some setup instruction can be found on [GitHub](https://github.com/axelhodler/heator).

Article has been cross-posted on [Medium](https://medium.com/@axelhodler/creating-a-heat-map-from-coordinates-using-r-780db4901075).
