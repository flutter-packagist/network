// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$ServiceRouter(Service service) {
  final router = Router();
  router.add(
    'GET',
    r'/get',
    service._get,
  );
  router.add(
    'POST',
    r'/post',
    service._post,
  );
  router.add(
    'PUT',
    r'/put',
    service._put,
  );
  router.add(
    'DELETE',
    r'/delete',
    service._delete,
  );
  router.add(
    'HEAD',
    r'/head',
    service._head,
  );
  router.add(
    'POST',
    r'/upload',
    service._upload,
  );
  router.add(
    'GET',
    r'/list',
    service._list,
  );
  router.add(
    'GET',
    r'/say-hi/<name>',
    service._hi,
  );
  router.add(
    'GET',
    r'/user/<userId|[0-9]+>',
    service._user,
  );
  router.add(
    'GET',
    r'/wave',
    service._wave,
  );
  router.all(
    r'/<ignored|.*>',
    service._notFound,
  );
  return router;
}
