OPENSCAD=../openscad/openscad

dual-charger-holder.stl:

%.stl: %.scad
	$(OPENSCAD) -o $@ -d $@.deps $<
