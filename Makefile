/*
$@ expends to the current target == $(NAME)
$^ expends to all prerequisites == $(OBJS)
$< expands to the leftmost prerequisite == the first item ound in $(OBJS)
-o = specify the objects name
-c = options tells the compiler to only compile without linking
.phony = make will run regardless of whether a file with that name exist

Unlike with sources, when a header file is modified make has no way of knowing this and will not consider the executable to be out of date, and therefor will not rebuild it. In order to change this behavior we should add the appropriate header files as additional prerequisites:
-MMD will automatically generate a list of dependencies for each objects file encountered during the compilation. 
- MP option prevents errors that are triggerer if a header file has been deleted or renamed.

include in makefile = #include in C

LIB 

$(addprefix) make function that allows you to add a prefix 
- I tell the compiler where to find the lib header files
- L tells the linker where to look for the library
- l the name of this library without its conventional lib prefix
For example: -I lib/libarom/include -L lib/libarom -l arom
*/
####### BEGINNING #######

NAME := makefile101

####### INGREDIENTS - BUILD VARIABLES #######

LIBS        := arom base m #librairies to be used = my lib + system lib, m is not mentionned because it already exist it is a system librairies
LIBS_TARGET :=            \ #librairies to be built
    /libarom/libarom.a \
    /libbase/libbase.a

INCS        := include    \
    /libarom/include   \
    /libbase/include

SRC_DIR     := src # source directory
SRCS        :=  \ #source file
    arom/coco.c \
    base/milk.c \
    base/water.c
SRCS        := $(SRCS:%=$(SRC_DIR)/%)

BUILD_DIR   := .build #object directory #hidden build directory that will contain our dependency files in addition to our objects.
OBJS        := $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o) # object files .o
DEPS        := $(OBJS:.o=.d) #dependency files

CC	:= cc # compiler
CFLAGS	:= -Wall -Wextra -Werror # compiler flags
CPPFLAGS    := $(addprefix -I,$(INCS)) -MMD -MP # preprocessor's flags, allows to no longer have to write the full path of a header but only its file name in the sources ex : #include "lib.h" instad of #include "/path/.../lib.h"
AR	:= ar # creates a static library during the linking step of the build
ARFLAGS	:= -r -c -s #-r replace the older objects with the new ones with -c to create the library if it does not exist and -s to write an index into the archive or update an existing one.
LDFLAGS     := $(addprefix -L,$(dir $(LIBS_TARGET)))#linker flags
LDLIBS      := $(addprefix -l,$(LIBS)) # libraries name

####### USTENSILS - SHELL COMMANDS #######


RM	:= rm -f # force remove
MAKEFLAGS += --no-print-directory # make flags
DIR_DUP     = mkdir -p $(@D) # duplicate directory tree, DIR_DUP will generate the OBJ_DIR based on SRC_DIR structure with mkdir -p which creates the directory and the parents directories if missing, and $(@D)

####### RECIPES - BUILD EXTRA RULES #######

all: = $(NAME) # default goal
    
$(NAME): $(OBJS) $(LIBS_TARGET) # linking.o -> binary = .a
    $(AR) $(ARFLAGS) $(CC) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $(NAME)
    
$(LIBS_TARGET):
    $(MAKE) -C $(@D)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
    $(DIR_DUP)
    $(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

	
-include $(DEPS) # The purpose of the -include $(DEPS) initial hyphen symbol is to prevent make from complaining when a non-zero status code is encountered, which can be caused here by a missing files from our generated dependency files list.

clean: # remove .o
	$(RM) $(OBJS) $(DEPS)

fclean : clean #remove.o + binary .a
	$(RM) $(NAME)

re: # remake default goal
	$(MAKE) fclean
	$(MAKE) all

####### SPEC - SPECIAL TARGETS  #######

.PHONY: clean fclean re
.SILENT: # silences the rule output, To silence at the recipe-line level we can prefix the wanted recipe lines with an @ symbol.
