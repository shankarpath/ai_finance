// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Unknown'),
  );
  static const VerificationMeta _merchantCanonicalMeta = const VerificationMeta(
    'merchantCanonical',
  );
  @override
  late final GeneratedColumn<String> merchantCanonical =
      GeneratedColumn<String>(
        'merchant_canonical',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(AppCategory.others),
  );
  static const VerificationMeta _categorySourceMeta = const VerificationMeta(
    'categorySource',
  );
  @override
  late final GeneratedColumn<String> categorySource = GeneratedColumn<String>(
    'category_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<int> confidence = GeneratedColumn<int>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSubscriptionMeta = const VerificationMeta(
    'isSubscription',
  );
  @override
  late final GeneratedColumn<bool> isSubscription = GeneratedColumn<bool>(
    'is_subscription',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_subscription" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountLast4Meta = const VerificationMeta(
    'accountLast4',
  );
  @override
  late final GeneratedColumn<String> accountLast4 = GeneratedColumn<String>(
    'account_last4',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _smsBodyMeta = const VerificationMeta(
    'smsBody',
  );
  @override
  late final GeneratedColumn<String> smsBody = GeneratedColumn<String>(
    'sms_body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _smsIdMeta = const VerificationMeta('smsId');
  @override
  late final GeneratedColumn<String> smsId = GeneratedColumn<String>(
    'sms_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('posted'),
  );
  static const VerificationMeta _referenceNoMeta = const VerificationMeta(
    'referenceNo',
  );
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
    'reference_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsReviewMeta = const VerificationMeta(
    'needsReview',
  );
  @override
  late final GeneratedColumn<bool> needsReview = GeneratedColumn<bool>(
    'needs_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    merchant,
    merchantCanonical,
    category,
    categorySource,
    confidence,
    isSubscription,
    transactionType,
    paymentMethod,
    accountLast4,
    balance,
    date,
    smsBody,
    smsId,
    status,
    referenceNo,
    needsReview,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('merchant_canonical')) {
      context.handle(
        _merchantCanonicalMeta,
        merchantCanonical.isAcceptableOrUnknown(
          data['merchant_canonical']!,
          _merchantCanonicalMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('category_source')) {
      context.handle(
        _categorySourceMeta,
        categorySource.isAcceptableOrUnknown(
          data['category_source']!,
          _categorySourceMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('is_subscription')) {
      context.handle(
        _isSubscriptionMeta,
        isSubscription.isAcceptableOrUnknown(
          data['is_subscription']!,
          _isSubscriptionMeta,
        ),
      );
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('account_last4')) {
      context.handle(
        _accountLast4Meta,
        accountLast4.isAcceptableOrUnknown(
          data['account_last4']!,
          _accountLast4Meta,
        ),
      );
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sms_body')) {
      context.handle(
        _smsBodyMeta,
        smsBody.isAcceptableOrUnknown(data['sms_body']!, _smsBodyMeta),
      );
    } else if (isInserting) {
      context.missing(_smsBodyMeta);
    }
    if (data.containsKey('sms_id')) {
      context.handle(
        _smsIdMeta,
        smsId.isAcceptableOrUnknown(data['sms_id']!, _smsIdMeta),
      );
    } else if (isInserting) {
      context.missing(_smsIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('reference_no')) {
      context.handle(
        _referenceNoMeta,
        referenceNo.isAcceptableOrUnknown(
          data['reference_no']!,
          _referenceNoMeta,
        ),
      );
    }
    if (data.containsKey('needs_review')) {
      context.handle(
        _needsReviewMeta,
        needsReview.isAcceptableOrUnknown(
          data['needs_review']!,
          _needsReviewMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      merchantCanonical: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_canonical'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      categorySource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_source'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confidence'],
      ),
      isSubscription: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_subscription'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      accountLast4: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_last4'],
      ),
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      smsBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sms_body'],
      )!,
      smsId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sms_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      referenceNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_no'],
      ),
      needsReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_review'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final double amount;

  /// The raw merchant/payee string as detected from the SMS.
  final String merchant;

  /// Normalised, display/grouping name (e.g. "upiswiggy@icici" -> "Swiggy").
  /// Falls back to [merchant] when null.
  final String? merchantCanonical;
  final String category;

  /// How [category] was assigned: 'rule', 'ai', or 'user'.
  final String? categorySource;

  /// Confidence (0–100) in [category], when known (mainly for AI/rule guesses).
  final int? confidence;

  /// True when this looks like a recurring subscription charge.
  final bool isSubscription;

  /// 'debit' or 'credit'.
  final String transactionType;
  final String? paymentMethod;
  final String? accountLast4;
  final double? balance;
  final DateTime date;
  final String smsBody;

  /// Stable per-SMS id used to prevent duplicate inserts on re-scan.
  final String smsId;

  /// 'posted' (money moved), 'failed' (declined/timed out), or 'reversed'
  /// (debit rolled back). Only 'posted' rows count towards analytics; the
  /// others are kept for the audit trail.
  final String status;

  /// Bank/UPI reference number (UTR), when the SMS exposed one. Used to spot
  /// the same payment being announced by two senders (bank + UPI app).
  final String? referenceNo;

  /// True when the categorization was too uncertain to trust silently
  /// (confidence < 80). Surfaced in the Review screen until the user confirms
  /// or corrects it.
  final bool needsReview;
  const Transaction({
    required this.id,
    required this.amount,
    required this.merchant,
    this.merchantCanonical,
    required this.category,
    this.categorySource,
    this.confidence,
    required this.isSubscription,
    required this.transactionType,
    this.paymentMethod,
    this.accountLast4,
    this.balance,
    required this.date,
    required this.smsBody,
    required this.smsId,
    required this.status,
    this.referenceNo,
    required this.needsReview,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['merchant'] = Variable<String>(merchant);
    if (!nullToAbsent || merchantCanonical != null) {
      map['merchant_canonical'] = Variable<String>(merchantCanonical);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || categorySource != null) {
      map['category_source'] = Variable<String>(categorySource);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<int>(confidence);
    }
    map['is_subscription'] = Variable<bool>(isSubscription);
    map['transaction_type'] = Variable<String>(transactionType);
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || accountLast4 != null) {
      map['account_last4'] = Variable<String>(accountLast4);
    }
    if (!nullToAbsent || balance != null) {
      map['balance'] = Variable<double>(balance);
    }
    map['date'] = Variable<DateTime>(date);
    map['sms_body'] = Variable<String>(smsBody);
    map['sms_id'] = Variable<String>(smsId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || referenceNo != null) {
      map['reference_no'] = Variable<String>(referenceNo);
    }
    map['needs_review'] = Variable<bool>(needsReview);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      merchant: Value(merchant),
      merchantCanonical: merchantCanonical == null && nullToAbsent
          ? const Value.absent()
          : Value(merchantCanonical),
      category: Value(category),
      categorySource: categorySource == null && nullToAbsent
          ? const Value.absent()
          : Value(categorySource),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      isSubscription: Value(isSubscription),
      transactionType: Value(transactionType),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      accountLast4: accountLast4 == null && nullToAbsent
          ? const Value.absent()
          : Value(accountLast4),
      balance: balance == null && nullToAbsent
          ? const Value.absent()
          : Value(balance),
      date: Value(date),
      smsBody: Value(smsBody),
      smsId: Value(smsId),
      status: Value(status),
      referenceNo: referenceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNo),
      needsReview: Value(needsReview),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      merchant: serializer.fromJson<String>(json['merchant']),
      merchantCanonical: serializer.fromJson<String?>(
        json['merchantCanonical'],
      ),
      category: serializer.fromJson<String>(json['category']),
      categorySource: serializer.fromJson<String?>(json['categorySource']),
      confidence: serializer.fromJson<int?>(json['confidence']),
      isSubscription: serializer.fromJson<bool>(json['isSubscription']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      accountLast4: serializer.fromJson<String?>(json['accountLast4']),
      balance: serializer.fromJson<double?>(json['balance']),
      date: serializer.fromJson<DateTime>(json['date']),
      smsBody: serializer.fromJson<String>(json['smsBody']),
      smsId: serializer.fromJson<String>(json['smsId']),
      status: serializer.fromJson<String>(json['status']),
      referenceNo: serializer.fromJson<String?>(json['referenceNo']),
      needsReview: serializer.fromJson<bool>(json['needsReview']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'merchant': serializer.toJson<String>(merchant),
      'merchantCanonical': serializer.toJson<String?>(merchantCanonical),
      'category': serializer.toJson<String>(category),
      'categorySource': serializer.toJson<String?>(categorySource),
      'confidence': serializer.toJson<int?>(confidence),
      'isSubscription': serializer.toJson<bool>(isSubscription),
      'transactionType': serializer.toJson<String>(transactionType),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'accountLast4': serializer.toJson<String?>(accountLast4),
      'balance': serializer.toJson<double?>(balance),
      'date': serializer.toJson<DateTime>(date),
      'smsBody': serializer.toJson<String>(smsBody),
      'smsId': serializer.toJson<String>(smsId),
      'status': serializer.toJson<String>(status),
      'referenceNo': serializer.toJson<String?>(referenceNo),
      'needsReview': serializer.toJson<bool>(needsReview),
    };
  }

  Transaction copyWith({
    int? id,
    double? amount,
    String? merchant,
    Value<String?> merchantCanonical = const Value.absent(),
    String? category,
    Value<String?> categorySource = const Value.absent(),
    Value<int?> confidence = const Value.absent(),
    bool? isSubscription,
    String? transactionType,
    Value<String?> paymentMethod = const Value.absent(),
    Value<String?> accountLast4 = const Value.absent(),
    Value<double?> balance = const Value.absent(),
    DateTime? date,
    String? smsBody,
    String? smsId,
    String? status,
    Value<String?> referenceNo = const Value.absent(),
    bool? needsReview,
  }) => Transaction(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    merchant: merchant ?? this.merchant,
    merchantCanonical: merchantCanonical.present
        ? merchantCanonical.value
        : this.merchantCanonical,
    category: category ?? this.category,
    categorySource: categorySource.present
        ? categorySource.value
        : this.categorySource,
    confidence: confidence.present ? confidence.value : this.confidence,
    isSubscription: isSubscription ?? this.isSubscription,
    transactionType: transactionType ?? this.transactionType,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    accountLast4: accountLast4.present ? accountLast4.value : this.accountLast4,
    balance: balance.present ? balance.value : this.balance,
    date: date ?? this.date,
    smsBody: smsBody ?? this.smsBody,
    smsId: smsId ?? this.smsId,
    status: status ?? this.status,
    referenceNo: referenceNo.present ? referenceNo.value : this.referenceNo,
    needsReview: needsReview ?? this.needsReview,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      merchantCanonical: data.merchantCanonical.present
          ? data.merchantCanonical.value
          : this.merchantCanonical,
      category: data.category.present ? data.category.value : this.category,
      categorySource: data.categorySource.present
          ? data.categorySource.value
          : this.categorySource,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      isSubscription: data.isSubscription.present
          ? data.isSubscription.value
          : this.isSubscription,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      accountLast4: data.accountLast4.present
          ? data.accountLast4.value
          : this.accountLast4,
      balance: data.balance.present ? data.balance.value : this.balance,
      date: data.date.present ? data.date.value : this.date,
      smsBody: data.smsBody.present ? data.smsBody.value : this.smsBody,
      smsId: data.smsId.present ? data.smsId.value : this.smsId,
      status: data.status.present ? data.status.value : this.status,
      referenceNo: data.referenceNo.present
          ? data.referenceNo.value
          : this.referenceNo,
      needsReview: data.needsReview.present
          ? data.needsReview.value
          : this.needsReview,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('merchant: $merchant, ')
          ..write('merchantCanonical: $merchantCanonical, ')
          ..write('category: $category, ')
          ..write('categorySource: $categorySource, ')
          ..write('confidence: $confidence, ')
          ..write('isSubscription: $isSubscription, ')
          ..write('transactionType: $transactionType, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('accountLast4: $accountLast4, ')
          ..write('balance: $balance, ')
          ..write('date: $date, ')
          ..write('smsBody: $smsBody, ')
          ..write('smsId: $smsId, ')
          ..write('status: $status, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('needsReview: $needsReview')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    merchant,
    merchantCanonical,
    category,
    categorySource,
    confidence,
    isSubscription,
    transactionType,
    paymentMethod,
    accountLast4,
    balance,
    date,
    smsBody,
    smsId,
    status,
    referenceNo,
    needsReview,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.merchant == this.merchant &&
          other.merchantCanonical == this.merchantCanonical &&
          other.category == this.category &&
          other.categorySource == this.categorySource &&
          other.confidence == this.confidence &&
          other.isSubscription == this.isSubscription &&
          other.transactionType == this.transactionType &&
          other.paymentMethod == this.paymentMethod &&
          other.accountLast4 == this.accountLast4 &&
          other.balance == this.balance &&
          other.date == this.date &&
          other.smsBody == this.smsBody &&
          other.smsId == this.smsId &&
          other.status == this.status &&
          other.referenceNo == this.referenceNo &&
          other.needsReview == this.needsReview);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> merchant;
  final Value<String?> merchantCanonical;
  final Value<String> category;
  final Value<String?> categorySource;
  final Value<int?> confidence;
  final Value<bool> isSubscription;
  final Value<String> transactionType;
  final Value<String?> paymentMethod;
  final Value<String?> accountLast4;
  final Value<double?> balance;
  final Value<DateTime> date;
  final Value<String> smsBody;
  final Value<String> smsId;
  final Value<String> status;
  final Value<String?> referenceNo;
  final Value<bool> needsReview;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.merchant = const Value.absent(),
    this.merchantCanonical = const Value.absent(),
    this.category = const Value.absent(),
    this.categorySource = const Value.absent(),
    this.confidence = const Value.absent(),
    this.isSubscription = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.accountLast4 = const Value.absent(),
    this.balance = const Value.absent(),
    this.date = const Value.absent(),
    this.smsBody = const Value.absent(),
    this.smsId = const Value.absent(),
    this.status = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.needsReview = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    this.merchant = const Value.absent(),
    this.merchantCanonical = const Value.absent(),
    this.category = const Value.absent(),
    this.categorySource = const Value.absent(),
    this.confidence = const Value.absent(),
    this.isSubscription = const Value.absent(),
    required String transactionType,
    this.paymentMethod = const Value.absent(),
    this.accountLast4 = const Value.absent(),
    this.balance = const Value.absent(),
    required DateTime date,
    required String smsBody,
    required String smsId,
    this.status = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.needsReview = const Value.absent(),
  }) : amount = Value(amount),
       transactionType = Value(transactionType),
       date = Value(date),
       smsBody = Value(smsBody),
       smsId = Value(smsId);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? merchant,
    Expression<String>? merchantCanonical,
    Expression<String>? category,
    Expression<String>? categorySource,
    Expression<int>? confidence,
    Expression<bool>? isSubscription,
    Expression<String>? transactionType,
    Expression<String>? paymentMethod,
    Expression<String>? accountLast4,
    Expression<double>? balance,
    Expression<DateTime>? date,
    Expression<String>? smsBody,
    Expression<String>? smsId,
    Expression<String>? status,
    Expression<String>? referenceNo,
    Expression<bool>? needsReview,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (merchant != null) 'merchant': merchant,
      if (merchantCanonical != null) 'merchant_canonical': merchantCanonical,
      if (category != null) 'category': category,
      if (categorySource != null) 'category_source': categorySource,
      if (confidence != null) 'confidence': confidence,
      if (isSubscription != null) 'is_subscription': isSubscription,
      if (transactionType != null) 'transaction_type': transactionType,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (accountLast4 != null) 'account_last4': accountLast4,
      if (balance != null) 'balance': balance,
      if (date != null) 'date': date,
      if (smsBody != null) 'sms_body': smsBody,
      if (smsId != null) 'sms_id': smsId,
      if (status != null) 'status': status,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (needsReview != null) 'needs_review': needsReview,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<double>? amount,
    Value<String>? merchant,
    Value<String?>? merchantCanonical,
    Value<String>? category,
    Value<String?>? categorySource,
    Value<int?>? confidence,
    Value<bool>? isSubscription,
    Value<String>? transactionType,
    Value<String?>? paymentMethod,
    Value<String?>? accountLast4,
    Value<double?>? balance,
    Value<DateTime>? date,
    Value<String>? smsBody,
    Value<String>? smsId,
    Value<String>? status,
    Value<String?>? referenceNo,
    Value<bool>? needsReview,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      merchantCanonical: merchantCanonical ?? this.merchantCanonical,
      category: category ?? this.category,
      categorySource: categorySource ?? this.categorySource,
      confidence: confidence ?? this.confidence,
      isSubscription: isSubscription ?? this.isSubscription,
      transactionType: transactionType ?? this.transactionType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountLast4: accountLast4 ?? this.accountLast4,
      balance: balance ?? this.balance,
      date: date ?? this.date,
      smsBody: smsBody ?? this.smsBody,
      smsId: smsId ?? this.smsId,
      status: status ?? this.status,
      referenceNo: referenceNo ?? this.referenceNo,
      needsReview: needsReview ?? this.needsReview,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (merchantCanonical.present) {
      map['merchant_canonical'] = Variable<String>(merchantCanonical.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (categorySource.present) {
      map['category_source'] = Variable<String>(categorySource.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<int>(confidence.value);
    }
    if (isSubscription.present) {
      map['is_subscription'] = Variable<bool>(isSubscription.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (accountLast4.present) {
      map['account_last4'] = Variable<String>(accountLast4.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (smsBody.present) {
      map['sms_body'] = Variable<String>(smsBody.value);
    }
    if (smsId.present) {
      map['sms_id'] = Variable<String>(smsId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (needsReview.present) {
      map['needs_review'] = Variable<bool>(needsReview.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('merchant: $merchant, ')
          ..write('merchantCanonical: $merchantCanonical, ')
          ..write('category: $category, ')
          ..write('categorySource: $categorySource, ')
          ..write('confidence: $confidence, ')
          ..write('isSubscription: $isSubscription, ')
          ..write('transactionType: $transactionType, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('accountLast4: $accountLast4, ')
          ..write('balance: $balance, ')
          ..write('date: $date, ')
          ..write('smsBody: $smsBody, ')
          ..write('smsId: $smsId, ')
          ..write('status: $status, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('needsReview: $needsReview')
          ..write(')'))
        .toString();
  }
}

class $MerchantMemoriesTable extends MerchantMemories
    with TableInfo<$MerchantMemoriesTable, MerchantMemory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantMemoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _canonicalMeta = const VerificationMeta(
    'canonical',
  );
  @override
  late final GeneratedColumn<String> canonical = GeneratedColumn<String>(
    'canonical',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  @override
  List<GeneratedColumn> get $columns => [canonical, category, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchant_memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MerchantMemory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('canonical')) {
      context.handle(
        _canonicalMeta,
        canonical.isAcceptableOrUnknown(data['canonical']!, _canonicalMeta),
      );
    } else if (isInserting) {
      context.missing(_canonicalMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {canonical};
  @override
  MerchantMemory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchantMemory(
      canonical: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $MerchantMemoriesTable createAlias(String alias) {
    return $MerchantMemoriesTable(attachedDatabase, alias);
  }
}

class MerchantMemory extends DataClass implements Insertable<MerchantMemory> {
  final String canonical;
  final String category;
  final String source;
  const MerchantMemory({
    required this.canonical,
    required this.category,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['canonical'] = Variable<String>(canonical);
    map['category'] = Variable<String>(category);
    map['source'] = Variable<String>(source);
    return map;
  }

  MerchantMemoriesCompanion toCompanion(bool nullToAbsent) {
    return MerchantMemoriesCompanion(
      canonical: Value(canonical),
      category: Value(category),
      source: Value(source),
    );
  }

  factory MerchantMemory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchantMemory(
      canonical: serializer.fromJson<String>(json['canonical']),
      category: serializer.fromJson<String>(json['category']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'canonical': serializer.toJson<String>(canonical),
      'category': serializer.toJson<String>(category),
      'source': serializer.toJson<String>(source),
    };
  }

  MerchantMemory copyWith({
    String? canonical,
    String? category,
    String? source,
  }) => MerchantMemory(
    canonical: canonical ?? this.canonical,
    category: category ?? this.category,
    source: source ?? this.source,
  );
  MerchantMemory copyWithCompanion(MerchantMemoriesCompanion data) {
    return MerchantMemory(
      canonical: data.canonical.present ? data.canonical.value : this.canonical,
      category: data.category.present ? data.category.value : this.category,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchantMemory(')
          ..write('canonical: $canonical, ')
          ..write('category: $category, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(canonical, category, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchantMemory &&
          other.canonical == this.canonical &&
          other.category == this.category &&
          other.source == this.source);
}

class MerchantMemoriesCompanion extends UpdateCompanion<MerchantMemory> {
  final Value<String> canonical;
  final Value<String> category;
  final Value<String> source;
  final Value<int> rowid;
  const MerchantMemoriesCompanion({
    this.canonical = const Value.absent(),
    this.category = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MerchantMemoriesCompanion.insert({
    required String canonical,
    required String category,
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : canonical = Value(canonical),
       category = Value(category);
  static Insertable<MerchantMemory> custom({
    Expression<String>? canonical,
    Expression<String>? category,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (canonical != null) 'canonical': canonical,
      if (category != null) 'category': category,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MerchantMemoriesCompanion copyWith({
    Value<String>? canonical,
    Value<String>? category,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return MerchantMemoriesCompanion(
      canonical: canonical ?? this.canonical,
      category: category ?? this.category,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (canonical.present) {
      map['canonical'] = Variable<String>(canonical.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchantMemoriesCompanion(')
          ..write('canonical: $canonical, ')
          ..write('category: $category, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyLimitMeta = const VerificationMeta(
    'monthlyLimit',
  );
  @override
  late final GeneratedColumn<double> monthlyLimit = GeneratedColumn<double>(
    'monthly_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [category, monthlyLimit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('monthly_limit')) {
      context.handle(
        _monthlyLimitMeta,
        monthlyLimit.isAcceptableOrUnknown(
          data['monthly_limit']!,
          _monthlyLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyLimitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {category};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      monthlyLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_limit'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String category;
  final double monthlyLimit;
  const Budget({required this.category, required this.monthlyLimit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category'] = Variable<String>(category);
    map['monthly_limit'] = Variable<double>(monthlyLimit);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      category: Value(category),
      monthlyLimit: Value(monthlyLimit),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      category: serializer.fromJson<String>(json['category']),
      monthlyLimit: serializer.fromJson<double>(json['monthlyLimit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'category': serializer.toJson<String>(category),
      'monthlyLimit': serializer.toJson<double>(monthlyLimit),
    };
  }

  Budget copyWith({String? category, double? monthlyLimit}) => Budget(
    category: category ?? this.category,
    monthlyLimit: monthlyLimit ?? this.monthlyLimit,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      category: data.category.present ? data.category.value : this.category,
      monthlyLimit: data.monthlyLimit.present
          ? data.monthlyLimit.value
          : this.monthlyLimit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('category: $category, ')
          ..write('monthlyLimit: $monthlyLimit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(category, monthlyLimit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.category == this.category &&
          other.monthlyLimit == this.monthlyLimit);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> category;
  final Value<double> monthlyLimit;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.category = const Value.absent(),
    this.monthlyLimit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String category,
    required double monthlyLimit,
    this.rowid = const Value.absent(),
  }) : category = Value(category),
       monthlyLimit = Value(monthlyLimit);
  static Insertable<Budget> custom({
    Expression<String>? category,
    Expression<double>? monthlyLimit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (category != null) 'category': category,
      if (monthlyLimit != null) 'monthly_limit': monthlyLimit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? category,
    Value<double>? monthlyLimit,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (monthlyLimit.present) {
      map['monthly_limit'] = Variable<double>(monthlyLimit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('category: $category, ')
          ..write('monthlyLimit: $monthlyLimit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertLogsTable extends AlertLogs
    with TableInfo<$AlertLogsTable, AlertLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alert_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AlertLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertLog(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
    );
  }

  @override
  $AlertLogsTable createAlias(String alias) {
    return $AlertLogsTable(attachedDatabase, alias);
  }
}

class AlertLog extends DataClass implements Insertable<AlertLog> {
  final String key;
  const AlertLog({required this.key});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    return map;
  }

  AlertLogsCompanion toCompanion(bool nullToAbsent) {
    return AlertLogsCompanion(key: Value(key));
  }

  factory AlertLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertLog(key: serializer.fromJson<String>(json['key']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key)};
  }

  AlertLog copyWith({String? key}) => AlertLog(key: key ?? this.key);
  AlertLog copyWithCompanion(AlertLogsCompanion data) {
    return AlertLog(key: data.key.present ? data.key.value : this.key);
  }

  @override
  String toString() {
    return (StringBuffer('AlertLog(')
          ..write('key: $key')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => key.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AlertLog && other.key == this.key);
}

class AlertLogsCompanion extends UpdateCompanion<AlertLog> {
  final Value<String> key;
  final Value<int> rowid;
  const AlertLogsCompanion({
    this.key = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertLogsCompanion.insert({
    required String key,
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AlertLog> custom({
    Expression<String>? key,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertLogsCompanion copyWith({Value<String>? key, Value<int>? rowid}) {
    return AlertLogsCompanion(key: key ?? this.key, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertLogsCompanion(')
          ..write('key: $key, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $MerchantMemoriesTable merchantMemories = $MerchantMemoriesTable(
    this,
  );
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $AlertLogsTable alertLogs = $AlertLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    merchantMemories,
    budgets,
    alertLogs,
  ];
}

typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required double amount,
      Value<String> merchant,
      Value<String?> merchantCanonical,
      Value<String> category,
      Value<String?> categorySource,
      Value<int?> confidence,
      Value<bool> isSubscription,
      required String transactionType,
      Value<String?> paymentMethod,
      Value<String?> accountLast4,
      Value<double?> balance,
      required DateTime date,
      required String smsBody,
      required String smsId,
      Value<String> status,
      Value<String?> referenceNo,
      Value<bool> needsReview,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<double> amount,
      Value<String> merchant,
      Value<String?> merchantCanonical,
      Value<String> category,
      Value<String?> categorySource,
      Value<int?> confidence,
      Value<bool> isSubscription,
      Value<String> transactionType,
      Value<String?> paymentMethod,
      Value<String?> accountLast4,
      Value<double?> balance,
      Value<DateTime> date,
      Value<String> smsBody,
      Value<String> smsId,
      Value<String> status,
      Value<String?> referenceNo,
      Value<bool> needsReview,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchantCanonical => $composableBuilder(
    column: $table.merchantCanonical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categorySource => $composableBuilder(
    column: $table.categorySource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSubscription => $composableBuilder(
    column: $table.isSubscription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountLast4 => $composableBuilder(
    column: $table.accountLast4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smsBody => $composableBuilder(
    column: $table.smsBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchantCanonical => $composableBuilder(
    column: $table.merchantCanonical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categorySource => $composableBuilder(
    column: $table.categorySource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSubscription => $composableBuilder(
    column: $table.isSubscription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountLast4 => $composableBuilder(
    column: $table.accountLast4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smsBody => $composableBuilder(
    column: $table.smsBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get merchantCanonical => $composableBuilder(
    column: $table.merchantCanonical,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get categorySource => $composableBuilder(
    column: $table.categorySource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSubscription => $composableBuilder(
    column: $table.isSubscription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountLast4 => $composableBuilder(
    column: $table.accountLast4,
    builder: (column) => column,
  );

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get smsBody =>
      $composableBuilder(column: $table.smsBody, builder: (column) => column);

  GeneratedColumn<String> get smsId =>
      $composableBuilder(column: $table.smsId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get referenceNo => $composableBuilder(
    column: $table.referenceNo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String?> merchantCanonical = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> categorySource = const Value.absent(),
                Value<int?> confidence = const Value.absent(),
                Value<bool> isSubscription = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> accountLast4 = const Value.absent(),
                Value<double?> balance = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> smsBody = const Value.absent(),
                Value<String> smsId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amount: amount,
                merchant: merchant,
                merchantCanonical: merchantCanonical,
                category: category,
                categorySource: categorySource,
                confidence: confidence,
                isSubscription: isSubscription,
                transactionType: transactionType,
                paymentMethod: paymentMethod,
                accountLast4: accountLast4,
                balance: balance,
                date: date,
                smsBody: smsBody,
                smsId: smsId,
                status: status,
                referenceNo: referenceNo,
                needsReview: needsReview,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double amount,
                Value<String> merchant = const Value.absent(),
                Value<String?> merchantCanonical = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> categorySource = const Value.absent(),
                Value<int?> confidence = const Value.absent(),
                Value<bool> isSubscription = const Value.absent(),
                required String transactionType,
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> accountLast4 = const Value.absent(),
                Value<double?> balance = const Value.absent(),
                required DateTime date,
                required String smsBody,
                required String smsId,
                Value<String> status = const Value.absent(),
                Value<String?> referenceNo = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                amount: amount,
                merchant: merchant,
                merchantCanonical: merchantCanonical,
                category: category,
                categorySource: categorySource,
                confidence: confidence,
                isSubscription: isSubscription,
                transactionType: transactionType,
                paymentMethod: paymentMethod,
                accountLast4: accountLast4,
                balance: balance,
                date: date,
                smsBody: smsBody,
                smsId: smsId,
                status: status,
                referenceNo: referenceNo,
                needsReview: needsReview,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$MerchantMemoriesTableCreateCompanionBuilder =
    MerchantMemoriesCompanion Function({
      required String canonical,
      required String category,
      Value<String> source,
      Value<int> rowid,
    });
typedef $$MerchantMemoriesTableUpdateCompanionBuilder =
    MerchantMemoriesCompanion Function({
      Value<String> canonical,
      Value<String> category,
      Value<String> source,
      Value<int> rowid,
    });

class $$MerchantMemoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MerchantMemoriesTable> {
  $$MerchantMemoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get canonical => $composableBuilder(
    column: $table.canonical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MerchantMemoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchantMemoriesTable> {
  $$MerchantMemoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get canonical => $composableBuilder(
    column: $table.canonical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MerchantMemoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchantMemoriesTable> {
  $$MerchantMemoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get canonical =>
      $composableBuilder(column: $table.canonical, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$MerchantMemoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MerchantMemoriesTable,
          MerchantMemory,
          $$MerchantMemoriesTableFilterComposer,
          $$MerchantMemoriesTableOrderingComposer,
          $$MerchantMemoriesTableAnnotationComposer,
          $$MerchantMemoriesTableCreateCompanionBuilder,
          $$MerchantMemoriesTableUpdateCompanionBuilder,
          (
            MerchantMemory,
            BaseReferences<
              _$AppDatabase,
              $MerchantMemoriesTable,
              MerchantMemory
            >,
          ),
          MerchantMemory,
          PrefetchHooks Function()
        > {
  $$MerchantMemoriesTableTableManager(
    _$AppDatabase db,
    $MerchantMemoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantMemoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchantMemoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchantMemoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> canonical = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MerchantMemoriesCompanion(
                canonical: canonical,
                category: category,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String canonical,
                required String category,
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MerchantMemoriesCompanion.insert(
                canonical: canonical,
                category: category,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MerchantMemoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MerchantMemoriesTable,
      MerchantMemory,
      $$MerchantMemoriesTableFilterComposer,
      $$MerchantMemoriesTableOrderingComposer,
      $$MerchantMemoriesTableAnnotationComposer,
      $$MerchantMemoriesTableCreateCompanionBuilder,
      $$MerchantMemoriesTableUpdateCompanionBuilder,
      (
        MerchantMemory,
        BaseReferences<_$AppDatabase, $MerchantMemoriesTable, MerchantMemory>,
      ),
      MerchantMemory,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String category,
      required double monthlyLimit,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> category,
      Value<double> monthlyLimit,
      Value<int> rowid,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => column,
  );
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> category = const Value.absent(),
                Value<double> monthlyLimit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                category: category,
                monthlyLimit: monthlyLimit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String category,
                required double monthlyLimit,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                category: category,
                monthlyLimit: monthlyLimit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;
typedef $$AlertLogsTableCreateCompanionBuilder =
    AlertLogsCompanion Function({required String key, Value<int> rowid});
typedef $$AlertLogsTableUpdateCompanionBuilder =
    AlertLogsCompanion Function({Value<String> key, Value<int> rowid});

class $$AlertLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertLogsTable> {
  $$AlertLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertLogsTable> {
  $$AlertLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertLogsTable> {
  $$AlertLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);
}

class $$AlertLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertLogsTable,
          AlertLog,
          $$AlertLogsTableFilterComposer,
          $$AlertLogsTableOrderingComposer,
          $$AlertLogsTableAnnotationComposer,
          $$AlertLogsTableCreateCompanionBuilder,
          $$AlertLogsTableUpdateCompanionBuilder,
          (AlertLog, BaseReferences<_$AppDatabase, $AlertLogsTable, AlertLog>),
          AlertLog,
          PrefetchHooks Function()
        > {
  $$AlertLogsTableTableManager(_$AppDatabase db, $AlertLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertLogsCompanion(key: key, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<int> rowid = const Value.absent(),
              }) => AlertLogsCompanion.insert(key: key, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertLogsTable,
      AlertLog,
      $$AlertLogsTableFilterComposer,
      $$AlertLogsTableOrderingComposer,
      $$AlertLogsTableAnnotationComposer,
      $$AlertLogsTableCreateCompanionBuilder,
      $$AlertLogsTableUpdateCompanionBuilder,
      (AlertLog, BaseReferences<_$AppDatabase, $AlertLogsTable, AlertLog>),
      AlertLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$MerchantMemoriesTableTableManager get merchantMemories =>
      $$MerchantMemoriesTableTableManager(_db, _db.merchantMemories);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$AlertLogsTableTableManager get alertLogs =>
      $$AlertLogsTableTableManager(_db, _db.alertLogs);
}
