#!/usr/bin/env bash

gp_save()
{
	printf "set size 1.0, 0.6;
		set terminal postscript portrait enhanced color dashed lw 2 \"Helvetica\" 20;
		set key right top;
		set output \"my-plot.ps\";
		replot;
		set terminal x11;
		set size 1,1;"
}

gp_plot_config()
{
    #set yrange [-0.1:1.1]; 
    printf "set title '$1';
    set xlabel 'Iterations';
    set ylabel 'Elastica ({/Symbol a}=0.1, {/Symbol b}=1)';"
}


gp_add_plot()
{
    printf "'$1' u 1:2 w l title '$2',"
}

gp_last_plot()
{
	printf "'$1' u 1:2 w l title '$2';"
}


create_multiplot()
{
	fileoutput=$1;shift;
	plottitle="$1";shift;

	buffer="$(gp_plot_config "$plottitle")plot "
	i=0
	num_plots=`expr ${#} / 2 - 1`

	while [ ${i} -lt ${num_plots} ]
	do
		subplotDataFile=$1
		subplotTitle=$2
		buffer="${buffer}$(gp_add_plot $subplotDataFile $subplotTitle)"
		shift; shift;

		i=`expr $i + 1`
	done

	if [ $num_plots -eq 0 ]
	then
		buffer="${buffer}$(gp_last_plot $1 $2)"
	else
		buffer="${buffer}$(gp_last_plot $1 $2)"
	fi

	buffer="${buffer}$(gp_save)"


	`gnuplot -e "$buffer"`
	`mv my-plot.ps ${fileoutput}`
}




BASE_FOLDER=$(realpath $1)
PLOTS_OUTPUT=$(realpath $2)
FILENAME_OUTPUT=$3

mkdir -p $PLOTS_OUTPUT
OUTPUT_PLOT=${PLOTS_OUTPUT}/${FILENAME_OUTPUT}


PLOT_STRING="$OUTPUT_PLOT ''"
PLOT_STRING="${PLOT_STRING} ${BASE_FOLDER}/output/model/h$gs/radius-$radius/$shape/$method/$mode/level-$i.txt m=$i"

create_multiplot ${OUTPUT_PLOT} "" ${BASE_FOLDER}/square/h1/energy.txt "square(h=1)" \
${BASE_FOLDER}/square/h05/energy.txt "square(h=0.5)" \
${BASE_FOLDER}/flower/h1/energy.txt "flower(h=1)" \
${BASE_FOLDER}/flower/h05/energy.txt "flower(h=0.5)"

