/* Copyright © 2022 Roel Janssen <roel@roelj.com>
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

#include "ui.h"
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

#include "runtime_configuration.h"
extern RuntimeConfiguration config;

void
ui_show_help (void)
{
  puts ("\nAvailable options:\n"
       "  --help,            -h  Show this message.\n"
       "  --version,         -v  Show versioning information.\n"
       "  --server-url=ARG,  -s  URL of the server to connect to.\n"
       "  --token=ARG,       -t  Token to authenticate to the server.\n");
}

void
ui_show_version (void)
{
  /* The VERSION variable is defined by the build system. */
  puts ("Version: " VERSION "\n");
}

void
ui_process_command_line (int argc, char **argv)
{
  int arg = 0;
  int index = 0;

  /* Program options
   * ------------------------------------------------------------------- */
  static struct option options[] =
    {
      { "server-url",            required_argument, 0, 's' },
      { "token",                 required_argument, 0, 't' },
      { "help",                  no_argument,       0, 'h' },
      { "version",               no_argument,       0, 'v' },
      { 0,                       0,                 0, 0   }
    };

  while ( arg != -1 )
    {
      /* Make sure to list all short options in the string below. */
      arg = getopt_long (argc, argv, "i:O:H:Ihv", options, &index);
      switch (arg)
        {
        case 's': config.server_url = optarg;        break;
        case 't': config.server_token = optarg;      break;
        case 'h': ui_show_help ();                   break;
        case 'v': ui_show_version ();                break;
        }

      /* When a required argument is missing, quit the program.
       * An error message will be displayed by getopt. */
      if (arg == '?') exit (1);
    }
}
