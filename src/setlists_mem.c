/* Copyright © 2019, 2023 Roel Janssen <roel@roelj.com>
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

#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

#include "setlists_mem.h"

void
preset_free (void *item)
{
  if (item == NULL)
    return;

  preset_t *preset = (preset_t *)item;
  free (preset->path);
  preset->path = NULL;
  free (item);
}

void
setlist_free (void *item)
{
  if (item == NULL)
    return;

  setlist_t *setlist = (setlist_t *)item;
  free (setlist->path);
  setlist->path = NULL;
  list_free_all (setlist->presets, preset_free);
  setlist->presets = NULL;
  free (item);
}

/*
 * We implement a streaming XML parser using SAX.  The libxml2 parser calls
 * functions upon encountering a certain event.
 */

void
parse_attributes (void *ctx, const xmlChar **attributes, setlist_or_preset_t *item)
{
  assert (item != NULL);
  assert (attributes != NULL);

  int attribute_index = 0;
  char *key, *value;
  while (attributes[attribute_index] != NULL)
    {
      key   = (char *)attributes[attribute_index];
      value = (char *)attributes[attribute_index + 1];

      if (key == NULL || value == NULL)
        break;

      if (!strcmp (key, "hash"))
        item->hash = strtoul (value, NULL, 10);
      else if (!strcmp (key, "path"))
        item->path = strdup (value);

      attribute_index += 2;
    }
}

/* This function is called to report the start of an element.
 * ------------------------------------------------------------------------- */
static void
on_start_element (void *ctx, const xmlChar *name, const xmlChar **attributes)
{
  char *element_name = (char *)name;
  setlist_t *current_setlist = NULL;

  if (! strcmp (element_name, "Setlist"))
    {
      current_setlist = calloc (1, sizeof (setlist_t));
      assert (current_setlist != NULL);
      if (attributes)
        parse_attributes (ctx, attributes, (setlist_or_preset_t *)current_setlist);

      global_setlists = list_prepend (global_setlists, current_setlist);
    }
  else if (! strcmp (element_name, "Preset"))
    {
      current_setlist = global_setlists->data;
      if (current_setlist == NULL)
        {
          fprintf (stderr, "Encountered a preset outside of a setlist.\n");
          return;
        }

      preset_t *preset = calloc (1, sizeof (preset_t));
      assert (preset != NULL);
      if (attributes)
        parse_attributes (ctx, attributes, (setlist_or_preset_t *)preset);

      list_t *presets = current_setlist->presets;
      current_setlist->presets = list_prepend (presets, preset);
    }
}

/* This function is called to report the end has been reached of an element.
 * ------------------------------------------------------------------------- */
static void
on_end_element (void *ctx, const xmlChar *name)
{
  /* Nothing to do here. */
}


/* This function is called to catch the value of an element.
 * ------------------------------------------------------------------------- */
static void
on_value (void *ctx, const xmlChar *value, int len)
{
  puts(__func__);
  /* The current 'setlists' file only contains attributes. */
  fprintf (stderr, "on_value was called.\n");
}

static xmlEntityPtr
get_entity (void *ctx, const xmlChar *name)
{
  puts(__func__);
  return xmlGetPredefinedEntity (name);
}

/* This function creates the parser and sets the callback functions.
 * ------------------------------------------------------------------------- */
xmlSAXHandler make_sax_handler (void)
{
  xmlSAXHandler handler;
  memset (&handler, 0, sizeof (xmlSAXHandler));

  handler.initialized = XML_SAX2_MAGIC;
  handler.startElement = on_start_element;
  handler.endElement = on_end_element;
  handler.characters = on_value;
  handler.getEntity = get_entity;

  return handler;
}

list_t*
read_setlists_xml_file (char *filename)
{
  LIBXML_TEST_VERSION;

  char             buffer[4096];
  int              bytes_read = 0;
  bool             read_failed = false;
  xmlSAXHandler    handler;
  xmlParserCtxtPtr ctx;
  gzFile           stream;

  global_setlists = NULL;
  stream  = gzopen (filename, "r");
  handler = make_sax_handler ();
  ctx     = xmlCreatePushParserCtxt (&handler, NULL, buffer, bytes_read, NULL);

  while ((bytes_read = gzfread (buffer, 1, sizeof (buffer), stream)) > 0)
    {
      if (xmlParseChunk (ctx, buffer, bytes_read, 0))
        {
          xmlParserError(ctx, "xmlParseChunk");
          read_failed = true;
          break;
        }
    }
  xmlParseChunk (ctx, buffer, 0, 1);
  xmlFreeParserCtxt (ctx);
  gzclose (stream);

  if (read_failed)
    return NULL;

  return global_setlists;
}
