import 'package:flutter_test/flutter_test.dart';
import 'package:hatua_app/src/data/counties.dart';
import 'package:hatua_app/src/models/opportunity.dart';
import 'package:hatua_app/src/models/support_resource.dart';
import 'package:hatua_app/src/widgets/directory_widgets.dart';

void main() {
  test('Opportunity parses optional deadline and verification time', () {
    final opportunity = Opportunity.fromJson({
      'id': '123', 'title': 'Training', 'organisation': 'Example',
      'summary': '', 'category': 'training', 'county': 'Nairobi',
      'deadline': null, 'last_verified_at': '2026-10-01T08:00:00Z',
    });
    expect(opportunity.deadline, isNull);
    expect(opportunity.county, 'Nairobi');
    expect(opportunity.lastVerifiedAt, DateTime.utc(2026, 10, 1, 8));
  });

  test('missing or malformed verification time is null, not a crash', () {
    final resource = SupportResource.fromJson({'id': 1, 'name': 'X', 'last_verified_at': 'not-a-date'});
    expect(resource.lastVerifiedAt, isNull);
    expect(resource.phone, '');
  });

  test('deadline stays open through the whole closing day', () {
    final op = Opportunity.fromJson({'id': 'a', 'deadline': '2026-10-18'});
    expect(op.isOpenOn(DateTime(2026, 10, 18, 23, 59)), isTrue);
    expect(op.isOpenOn(DateTime(2026, 10, 19)), isFalse);
    expect(Opportunity.fromJson({'id': 'b'}).isOpenOn(DateTime(2099)), isTrue);
  });

  test('county list has all 47 counties and nationwide matches everywhere', () {
    expect(kenyanCounties, hasLength(47));
    expect(kenyanCounties.toSet(), hasLength(47));
    expect(countyMatches(nationwide, 'Kisumu'), isTrue);
    expect(countyMatches('Nairobi', 'Kisumu'), isFalse);
    expect(countyMatches('Nairobi', null), isTrue);
  });

  test('only http(s) and tel links are opened', () {
    expect(isSafeExternalLink(Uri.parse('https://example.invalid')), isTrue);
    expect(isSafeExternalLink(Uri.parse('tel:1192')), isTrue);
    expect(isSafeExternalLink(Uri.parse('intent://scan#Intent;scheme=zxing;end')), isFalse);
    expect(isSafeExternalLink(Uri.parse('javascript:alert(1)')), isFalse);
    expect(isSafeExternalLink(Uri.parse('sms:0700000000')), isFalse);
  });

  test('phone numbers from remote data cannot inject dialer codes', () {
    expect(safeTelUri('0800 000-000'), 'tel:0800000000');
    expect(safeTelUri('+254 700 000 000'), 'tel:+254700000000');
    expect(safeTelUri('*144#'), 'tel:144');
    expect(safeTelUri('1192,,1234'), 'tel:11921234');
  });
}
