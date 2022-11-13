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

#include <stdio.h>
#include <curl/curl.h>
#include "ui.h"
#include "runtime_configuration.h"
extern RuntimeConfiguration config;

int
terminate_with_exit_code (CURL *curl, int exit_code)
{
 curl_easy_cleanup (curl);
 curl_global_cleanup ();
 return exit_code;
}

int
main (int argc, char **argv)
{
  if (argc > 1)
    ui_process_command_line (argc, argv);
  else
    ui_show_help ();

  curl_global_init (CURL_GLOBAL_ALL);

 CURL *curl = curl_easy_init ();
 if (! curl)
   {
     fprintf (stderr, "Unable to initialize cURL.\n");
     return terminate_with_exit_code (curl, 1);
   }

 if (!config.server_url || !config.server_token)
   {
     fprintf (stderr, "Please specify a --server-url and a --token.\n");
     return terminate_with_exit_code (curl, 1);
   }

 CURLcode curl_result;
 curl_easy_setopt (curl, CURLOPT_URL, config.server_url);
 curl_result = curl_easy_perform (curl);
 if (curl_result != CURLE_OK)
   fprintf (stderr, "Network error: %s\n", curl_easy_strerror (curl_result));

 return terminate_with_exit_code (curl, 0);
}
