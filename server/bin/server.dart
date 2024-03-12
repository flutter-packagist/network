// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async' show Future;
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:shelf_plus/shelf_plus.dart';

// Generated code will be written to 'main.g.dart'
part 'server.g.dart';

class Service {
  @Route.get('/get')
  Response _get(Request request) => Response.ok('get success');

  @Route.post('/post')
  Response _post(Request request) => Response.ok('post success');

  @Route.put('/put')
  Response _put(Request request) => Response.ok('put success');

  @Route.delete('/delete')
  Response _delete(Request request) => Response.ok('delete success');

  @Route.head('/head')
  Response _head(Request request) => Response.ok('head success');

  @Route.post('/upload')
  Future<Response> _upload(Request request) async {
    if (!request.isMultipart) {
      return Response.ok('Not a multipart request');
    } else if (request.isMultipartForm) {
      final description = StringBuffer('Parsed form multipart request\n');
      await for (final formData in request.multipartFormData) {
        var formDataPart = await formData.part.readBytes();
        description.writeln('${formData.name}: $formDataPart');
      }
      return Response.ok(description.toString());
    } else {
      final description = StringBuffer('Regular multipart request\n');
      await for (final part in request.parts) {
        description.writeln('new part');
        part.headers
            .forEach((key, value) => description.writeln('Header $key=$value'));
        final content = await part.readString();
        description.writeln('content: $content');
        description.writeln('end of part');
      }
      return Response.ok(description.toString());
    }
  }

  @Route.get('/list')
  Response _list(Request request) {
    final query = request.url.queryParameters;
    final page = int.parse(query['page'] ?? '1');
    final limit = page > 3 ? 0 : int.parse(query['limit'] ?? '10');
    final list = List.generate(
        limit, (index) => {'title': "${(page - 1) * limit + index}"});
    return Response.ok(
      jsonEncode({'data': list}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // A handler is annotated with @Route.<verb>('<route>'), the '<route>' may
  // embed URL-parameters, and these may be taken as parameters by the handler.
  // But either all URL-parameters or none of the URL parameters must be taken
  // as parameters by the handler.
  @Route.get('/say-hi/<name>')
  Response _hi(Request request, String name) => Response.ok('hi $name');

  // Embedded URL parameters may also be associated with a regular-expression
  // that the pattern must match.
  @Route.get('/user/<userId|[0-9]+>')
  Response _user(Request request, String userId) =>
      Response.ok('User has the user-number: $userId');

  // Handlers can be asynchronous (returning `FutureOr` is also allowed).
  @Route.get('/wave')
  Future<Response> _wave(Request request) async {
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    return Response.ok('_o/');
  }

  // You can catch all verbs and use a URL-parameter with a regular expression
  // that matches everything to catch app.
  @Route.all('/<ignored|.*>')
  Response _notFound(Request request) => Response.notFound('Page not found');

  // The generated function _$ServiceRouter can be used to get a [Handler]
  // for this object. This can be used with [shelf_io.serve].
  Handler get handler => _$ServiceRouter(this).call;
}

// Run shelf server and host a [Service] instance on port 8080.
void main() async {
  final service = Service();
  final server = await shelf_io.serve(service.handler, InternetAddress.anyIPv4, 8080);
  print('Server running on localhost:${server.port}');
}
