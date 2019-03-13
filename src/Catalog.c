/// ____________________________________________________________________ ///
///                                                                      ///
/// SoFiA 2.0.0-beta (Catalog.c) - Source Finding Application            ///
/// Copyright (C) 2019 Tobias Westmeier                                  ///
/// ____________________________________________________________________ ///
///                                                                      ///
/// Address:  Tobias Westmeier                                           ///
///           ICRAR M468                                                 ///
///           The University of Western Australia                        ///
///           35 Stirling Highway                                        ///
///           Crawley WA 6009                                            ///
///           Australia                                                  ///
///                                                                      ///
/// E-mail:   tobias.westmeier [at] uwa.edu.au                           ///
/// ____________________________________________________________________ ///
///                                                                      ///
/// This program is free software: you can redistribute it and/or modify ///
/// it under the terms of the GNU General Public License as published by ///
/// the Free Software Foundation, either version 3 of the License, or    ///
/// (at your option) any later version.                                  ///
///                                                                      ///
/// This program is distributed in the hope that it will be useful,      ///
/// but WITHOUT ANY WARRANTY; without even the implied warranty of       ///
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         ///
/// GNU General Public License for more details.                         ///
///                                                                      ///
/// You should have received a copy of the GNU General Public License    ///
/// along with this program. If not, see http://www.gnu.org/licenses/.   ///
/// ____________________________________________________________________ ///
///                                                                      ///

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>

#include "Catalog.h"



// ----------------------------------------------------------------- //
// Declaration of private properties and methods of class Catalog    //
// ----------------------------------------------------------------- //

class Catalog
{
	size_t size;
	Source **sources;
};

private void Catalog_append_memory(Catalog *this);



// ----------------------------------------------------------------- //
// Standard constructor                                              //
// ----------------------------------------------------------------- //
// Arguments:                                                        //
//                                                                   //
//   No arguments.                                                   //
//                                                                   //
// Return value:                                                     //
//                                                                   //
//   Pointer to newly created Catalog object.                        //
//                                                                   //
// Description:                                                      //
//                                                                   //
//   Standard constructor. Will create a new and empty Catalog ob-   //
//   ject and return a pointer to the newly created object. No memo- //
//   ry will be allocated other than for the object itself. Note     //
//   that the destructor will need to be called explicitly once the  //
//   object is no longer required to release any memory allocated    //
//   during the lifetime of the object.                              //
// ----------------------------------------------------------------- //

public Catalog *Catalog_new(void)
{
	// Allocate memory for new catalog
	Catalog *this = (Catalog*)malloc(sizeof(Catalog));
	ensure(this != NULL, "Failed to allocate memory for new catalogue object.");
	
	// Initialise properties
	this->size = 0;
	this->sources = NULL;
	
	return this;
}



// ----------------------------------------------------------------- //
// Destructor                                                        //
// ----------------------------------------------------------------- //
// Arguments:                                                        //
//                                                                   //
//   (1) this     - Object self-reference.                           //
//                                                                   //
// Return value:                                                     //
//                                                                   //
//   No return value.                                                //
//                                                                   //
// Description:                                                      //
//                                                                   //
//   Destructor. Note that the destructor must be called explicitly  //
//   if the object is no longer required. This will release the me-  //
//   mory occupied by the object.                                    //
//   NOTE that the destructor will explicitly call the destructor on //
//   all source objects stored in the catalogue. Hence, deleting a   //
//   catalogue will automatically delete all sources associated with //
//   that catalogue!                                                 //
// ----------------------------------------------------------------- //

public void Catalog_delete(Catalog *this)
{
	if(this != NULL)
	{
		if(this->sources != NULL)
		{
			// Call the destructor on individual sources first
			Source **ptr = this->sources + this->size;
			while(ptr --> this->sources) Source_delete(*ptr);
			
			// Then de-allocate memory for pointers to those sources
			free(this->sources);
		}
		
		// Lastly, de-allocate memory for catalog object
		free(this);
	}
	
	return;
}



// ----------------------------------------------------------------- //
// Add a new source to a catalogue                                   //
// ----------------------------------------------------------------- //
// Arguments:                                                        //
//                                                                   //
//   (1) this     - Object self-reference.                           //
//   (2) src      - Pointer to the source to be added                //
//                                                                   //
// Return value:                                                     //
//                                                                   //
//   No return value.                                                //
//                                                                   //
// Description:                                                      //
//                                                                   //
//   Public method for adding a new source to the specified cata-    //
//   logue. Note that the function does not check if a source with   //
//   the same name already exists; a new source will always be added //
//   to the existing source list.                                    //
// ----------------------------------------------------------------- //

public void Catalog_add_source(Catalog *this, Source *src)
{
	// Sanity checks
	check_null(this);
	check_null(src);
	ensure(!Catalog_source_exists(this, src, NULL), "Source \'%s\' is already in catalogue.", Source_get_identifier(src));
	
	Catalog_append_memory(this);
	*(this->sources + this->size - 1) = src;
	
	return;
}



// ----------------------------------------------------------------- //
// Get source index                                                  //
// ----------------------------------------------------------------- //
// Arguments:                                                        //
//                                                                   //
//   (1) this     - Object self-reference.                           //
//   (2) src      - Pointer to the source to be checked              //
//                                                                   //
// Return value:                                                     //
//                                                                   //
//   Returns the index (i.e. row number) of the source within the    //
//   catalogue if the source was found. Otherwise, SIZE_MAX will be  //
//   returned.                                                       //
//                                                                   //
// Description:                                                      //
//                                                                   //
//   Public method for checking if the specified source is included  //
//   in the catalogue. If so, the function will return the row num-  //
//   ber of the source in the catalogue (starting with 0). If the    //
//   source is not found, the function will return SIZE_MAX.         //
// ----------------------------------------------------------------- //

public size_t Catalog_get_index(const Catalog *this, const Source *src)
{
	// Sanity checks
	check_null(this);
	check_null(src);
	
	for(size_t i = 0; i < this->size; ++i)
	{
		if(this->sources[i] == src) return i;
	}
	
	return SIZE_MAX;
}



// ----------------------------------------------------------------- //
// Check if source exists in catalogue                               //
// ----------------------------------------------------------------- //
// Arguments:                                                        //
//                                                                   //
//   (1) this     - Object self-reference.                           //
//   (2) src      - Pointer to the source to be checked              //
//   (3) index    - Pointer to index variable that will be set to    //
//                  the catalogue index of the source.               //
//                                                                   //
// Return value:                                                     //
//                                                                   //
//   Returns true if the source is included in the catalogue and     //
//   false otherwise.                                                //
//                                                                   //
// Description:                                                      //
//                                                                   //
//   Public method for checking if the specified source is included  //
//   in the catalogue. If so, the function will return true, other-  //
//   wise false. If the source is found, the variable 'index' will   //
//   be set to the catalogue index of the source. Otherwise, it will //
//   be left untouched. If no index is required, a NULL pointer can  //
//   instead be provided.
// ----------------------------------------------------------------- //

public bool Catalog_source_exists(const Catalog *this, const Source *src, size_t *index)
{
	// Sanity checks
	check_null(this);
	check_null(src);
	
	for(size_t i = 0; i < this->size; ++i)
	{
		if(this->sources[i] == src)
		{
			if(index != NULL) *index = i;
			return true;
		}
	}
	
	return false;
}



// ----------------------------------------------------------------- //
// Retrieve a source from the catalogue by index                     //
// ----------------------------------------------------------------- //
// Arguments:                                                        //
//                                                                   //
//   (1) this       - Object self-reference.                         //
//   (2) index      - Index of requested source.                     //
//                                                                   //
// Return value:                                                     //
//                                                                   //
//   Returns a pointer to the requested source.                      //
//                                                                   //
// Description:                                                      //
//                                                                   //
//   Public method for extracting a specific source from the cata-   //
//   logue by its index. A pointer to the source will be returned.   //
// ----------------------------------------------------------------- //

public Source *Catalog_get_source(const Catalog *this, const size_t index)
{
	check_null(this);
	ensure(index < this->size, "Catalogue index out of range.");
	
	return this->sources[index];
}




// ----------------------------------------------------------------- //
// Return size of catalogue                                          //
// ----------------------------------------------------------------- //
// Arguments:                                                        //
//                                                                   //
//   (1) this - Object self-reference.                               //
//                                                                   //
// Return value:                                                     //
//                                                                   //
//   Returns the current size of the catalogue pointed to by 'this'. //
//                                                                   //
// Description:                                                      //
//                                                                   //
//   Returns the size of the catalogue, i.e. the number of sources   //
//   it contains. For empty catalogues a value of zero will be re-   //
//   turned.                                                         //
// ----------------------------------------------------------------- //

public size_t Catalog_get_size(const Catalog *this)
{
	return this->size;
}



// ----------------------------------------------------------------- //
// Save catalogue to file                                            //
// ----------------------------------------------------------------- //
// Arguments:                                                        //
//                                                                   //
//   (1) this     - Object self-reference.                           //
//   (2) filename - Full path to the output file.                    //
//   (3) format   - Output format; can be CATALOG_FORMAT_ASCII for   //
//                  plain text ASCII files, CATALOG_FORMAT_XML for   //
//                  VOTable format or CATALOG_FORMAT_SQL for SQL     //
//                  table format (not yet supported).                //
//                                                                   //
// Return value:                                                     //
//                                                                   //
//   No return value.                                                //
//                                                                   //
// Description:                                                      //
//                                                                   //
//   Public method for saving the current catalogue under the speci- //
//   fied name in the specified file format. The file name will be   //
//   relative to the process execution directory unless the full     //
//   path to the output directory is specified. Available formats    //
//   are plain text ASCII, VOTable XML format and SQL format.        //
// ----------------------------------------------------------------- //

public void Catalog_save(const Catalog *this, const char *filename, const file_format format)
{
	// Sanity checks
	ensure(this != NULL && this->size, "Invalid or empty catalogue provided.");
	
	// Open output file
	FILE *fp = fopen(filename, "w");
	ensure(fp != NULL, "Failed to open output file: %s", filename);
	
	// Some initial definitions
	const char char_comment = '#';
	const char char_nocomment = ' ';
	const char *data_type_names[2] = {"long", "double"};
	const char *indentation[7] = {"", "\t", "\t\t", "\t\t\t", "\t\t\t\t", "\t\t\t\t\t", "\t\t\t\t\t\t"}; // Better readability
	//const char *indentation[7] = {"", "", "", "", "", "", ""}; // Smaller file size
	
	// Get current date and time
	char current_time_string[64];
	strftime(current_time_string, 64, "%a, %d %b %Y, %H:%M:%S", localtime(&(time_t){time(NULL)}));
	
	// Get first source to extract parameter names and units
	Source *src = this->sources[0];
	
	if(format == CATALOG_FORMAT_XML)
	{
		// Write XML catalogue (VOTable)
		fprintf(fp, "%s<?xml version=\"1.0\" ?>\n", indentation[0]);
		fprintf(fp, "%s<VOTABLE version=\"1.3\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://www.ivoa.net/xml/VOTable/v1.3\">\n", indentation[0]);
		fprintf(fp, "%s<RESOURCE>\n", indentation[1]);
		fprintf(fp, "%s<DESCRIPTION>Source catalogue created by the Source Finding Application (SoFiA)</DESCRIPTION>\n", indentation[2]);
		fprintf(fp, "%s<PARAM name=\"Creator\" datatype=\"char\" arraysize=\"*\" value=\"SoFiA %s\" ucd=\"meta.software\"/>\n", indentation[2], VERSION);
		fprintf(fp, "%s<PARAM name=\"Time\" datatype=\"char\" arraysize=\"*\" value=\"%s\" ucd=\"time.creation\"/>\n", indentation[2], current_time_string);
		//fprintf(fp, "%s<COOSYS ID=\"wcs\" system=\"ICRS\" equinox=\"J2000\"/>\n", indentation[2]);
		// WARNING: COOSYS needs to be sorted out; see http://www.ivoa.net/documents/VOTable/ for documentation
		fprintf(fp, "%s<TABLE name=\"SoFiA source catalogue\">\n", indentation[2]);
		
		// Column descriptors
		for(size_t j = 0; j < Source_get_num_par(src); ++j)
		{
			fprintf(fp, "%s<FIELD datatype=\"%s\" name=\"%s\" unit=\"%s\" ucd=\"%s\"/>\n", indentation[3], data_type_names[Source_get_type(src, j)], Source_get_name(src, j), Source_get_unit(src, j), Source_get_ucd(src, j));
		}
		
		// Start of data table
		fprintf(fp, "%s<DATA>\n", indentation[3]);
		fprintf(fp, "%s<TABLEDATA>\n", indentation[4]);
		
		// Data rows
		for(size_t i = 0; i < this->size; ++i)
		{
			Source *src = this->sources[i];
			fprintf(fp, "%s<TR>\n", indentation[5]);
			
			for(size_t j = 0; j < Source_get_num_par(src); ++j)
			{
				if(Source_get_type(src, j) == SOURCE_TYPE_INT)
				{
					// Integer value
					const long int value = Source_get_par_int(src, j);
					fprintf(fp, "%s<TD>%ld</TD>\n", indentation[6], value);
				}
				else
				{
					// Floating-point value
					const double value = Source_get_par_flt(src, j);
					fprintf(fp, "%s<TD>%.15e</TD>\n", indentation[6], value);
				}
			}
			
			fprintf(fp, "%s</TR>\n", indentation[5]);
		}
		
		// End of data table
		fprintf(fp, "%s</TABLEDATA>\n", indentation[4]);
		fprintf(fp, "%s</DATA>\n", indentation[3]);
		
		// Finalise XML file
		fprintf(fp, "%s</TABLE>\n", indentation[2]);
		fprintf(fp, "%s</RESOURCE>\n", indentation[1]);
		fprintf(fp, "%s</VOTABLE>\n", indentation[0]);
	}
	else
	{
		// Write ASCII catalogue
		fprintf(fp, "# SoFiA source catalogue\n# Creator: " VERSION_FULL "\n# Time:    %s\n#\n", current_time_string);
		fprintf(fp, "# Header rows:\n#   1 = column number\n#   2 = parameter name\n#   3 = parameter unit\n%c\n%c", char_comment, char_comment);
		for(size_t j = 0; j < Source_get_num_par(src); ++j) fprintf(fp, "%*zu", CATALOG_COLUMN_WIDTH, j + 1);
		fprintf(fp, "\n%c", char_comment);
		for(size_t j = 0; j < Source_get_num_par(src); ++j) fprintf(fp, "%*s", CATALOG_COLUMN_WIDTH, Source_get_name(src, j));
		fprintf(fp, "\n%c", char_comment);
		for(size_t j = 0; j < Source_get_num_par(src); ++j) fprintf(fp, "%*s", CATALOG_COLUMN_WIDTH, Source_get_unit(src, j));
		fprintf(fp, "\n\n");
		
		// Loop over all sources to write parameters
		for(size_t i = 0; i < this->size; ++i)
		{
			Source *src = this->sources[i];
			
			fprintf(fp, "%c", char_nocomment);
			
			for(size_t j = 0; j < Source_get_num_par(src); ++j)
			{
				if(Source_get_type(src, j) == SOURCE_TYPE_INT)
				{
					// Integer value
					const long int value = Source_get_par_int(src, j);
					fprintf(fp, "%*ld", CATALOG_COLUMN_WIDTH, value);
				}
				else
				{
					// Floating-point value
					const double value = Source_get_par_flt(src, j);
					if(fabs(value) >= 1.0e+4 || fabs(value) < 1.0e-3) fprintf(fp, "%*.5e", CATALOG_COLUMN_WIDTH, value);
					else fprintf(fp, "%*.6f", CATALOG_COLUMN_WIDTH, value);
				}
			}
			
			fprintf(fp, "\n");
		}
	}
	
	fclose(fp);
	
	return;
}



// ----------------------------------------------------------------- //
// Reallocate memory for one additional source                       //
// ----------------------------------------------------------------- //
// Arguments:                                                        //
//                                                                   //
//   (1) this     - Object self-reference.                           //
//                                                                   //
// Return value:                                                     //
//                                                                   //
//   No return value.                                                //
//                                                                   //
// Description:                                                      //
//                                                                   //
//   Private method for allocating additional memory for one more    //
//   source in the specified catalogue. Note that this will not cre- //
//   ate a new source yet, but just allocate the memory needed to    //
//   append a source at the end of the catalogue. The function       //
//   should be called from public member functions that will add     //
//   sources to a catalogue prior to inserting the new source.       //
// ----------------------------------------------------------------- //

private void Catalog_append_memory(Catalog *this)
{
	this->size += 1;
	this->sources = (Source **)realloc(this->sources, this->size * sizeof(Source *));
	ensure(this->sources != NULL, "Memory allocation for new catalogue source failed.");
	return;
}
