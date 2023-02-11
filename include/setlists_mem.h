/* Copyright © 2023 Roel Janssen <roel@roelj.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef SETLISTS_H
#define SETLISTS_H

#include <libxml/SAX.h>
#include "list.h"

typedef struct
{
  unsigned long hash;
  char *path;
} setlist_or_preset_t;

typedef setlist_or_preset_t preset_t;

typedef struct
{
  unsigned long hash;
  char *path;
  list_t *presets;
} setlist_t;

/* Callbacks for 'list_free_all'. */
void preset_free (void *item);
void setlist_free (void *item);

/* SAX parser. */
xmlSAXHandler make_sax_handler (void);
list_t * read_setlists_xml_file (char *filename);

/* Global state variables to keep track of the SAX parsing.
 * ------------------------------------------------------------------------- */
list_t    *global_setlists;
//char      output_buffer[8192] = { 0 };
//char      output_buffer_index;

/*
  USAGE EXAMPLE
  --------------------------------------------------------------------------

  list_t *setlists = read_setlists_xml_file ("/media/p4/Presets/setlists");
  assert (setlists != NULL);

  list_t *sl_node = setlists;
  list_t *ps_node = NULL;
  printf ("[");
  while (sl_node != NULL)
    {
      setlist_t *setlist = (setlist_t *)sl_node->data;
      printf ("{ \"hash\": %lu, \"path\": \"%s\", \"presets\": [", setlist->hash, setlist->path);
      ps_node = (list_t *)setlist->presets;
      while (ps_node != NULL)
        {
          preset_t *preset = (preset_t *)ps_node->data;
          printf ("{ \"hash\": %lu, \"path\": \"%s\" }", preset->hash, preset->path);

          ps_node = list_next(ps_node);
          if (ps_node != NULL)
            printf (",");
        }
      printf ("]}");
      sl_node = list_next (sl_node);
      if (sl_node != NULL)
        printf (",");
    }
  printf ("]\n");

  list_free_all (setlists, setlist_free);
  setlists = NULL;
*/

#endif /* SETLISTS_H */
