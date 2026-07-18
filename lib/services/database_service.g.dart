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

class $AiInsightsTable extends AiInsights
    with TableInfo<$AiInsightsTable, AiInsight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiInsightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodKeyMeta = const VerificationMeta(
    'periodKey',
  );
  @override
  late final GeneratedColumn<String> periodKey = GeneratedColumn<String>(
    'period_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [kind, periodKey, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_insights';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiInsight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('period_key')) {
      context.handle(
        _periodKeyMeta,
        periodKey.isAcceptableOrUnknown(data['period_key']!, _periodKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_periodKeyMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kind, periodKey};
  @override
  AiInsight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiInsight(
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      periodKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_key'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiInsightsTable createAlias(String alias) {
    return $AiInsightsTable(attachedDatabase, alias);
  }
}

class AiInsight extends DataClass implements Insertable<AiInsight> {
  /// 'briefing' | 'daily' | 'weekly' | 'monthly' | 'card'
  final String kind;

  /// e.g. '2026-07-09' (daily kinds), '2026-W28' (weekly), '2026-07' (monthly).
  final String periodKey;

  /// Markdown content.
  final String content;
  final DateTime createdAt;
  const AiInsight({
    required this.kind,
    required this.periodKey,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['kind'] = Variable<String>(kind);
    map['period_key'] = Variable<String>(periodKey);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiInsightsCompanion toCompanion(bool nullToAbsent) {
    return AiInsightsCompanion(
      kind: Value(kind),
      periodKey: Value(periodKey),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory AiInsight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiInsight(
      kind: serializer.fromJson<String>(json['kind']),
      periodKey: serializer.fromJson<String>(json['periodKey']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'kind': serializer.toJson<String>(kind),
      'periodKey': serializer.toJson<String>(periodKey),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiInsight copyWith({
    String? kind,
    String? periodKey,
    String? content,
    DateTime? createdAt,
  }) => AiInsight(
    kind: kind ?? this.kind,
    periodKey: periodKey ?? this.periodKey,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  AiInsight copyWithCompanion(AiInsightsCompanion data) {
    return AiInsight(
      kind: data.kind.present ? data.kind.value : this.kind,
      periodKey: data.periodKey.present ? data.periodKey.value : this.periodKey,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiInsight(')
          ..write('kind: $kind, ')
          ..write('periodKey: $periodKey, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(kind, periodKey, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiInsight &&
          other.kind == this.kind &&
          other.periodKey == this.periodKey &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class AiInsightsCompanion extends UpdateCompanion<AiInsight> {
  final Value<String> kind;
  final Value<String> periodKey;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AiInsightsCompanion({
    this.kind = const Value.absent(),
    this.periodKey = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiInsightsCompanion.insert({
    required String kind,
    required String periodKey,
    required String content,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : kind = Value(kind),
       periodKey = Value(periodKey),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<AiInsight> custom({
    Expression<String>? kind,
    Expression<String>? periodKey,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (kind != null) 'kind': kind,
      if (periodKey != null) 'period_key': periodKey,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiInsightsCompanion copyWith({
    Value<String>? kind,
    Value<String>? periodKey,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AiInsightsCompanion(
      kind: kind ?? this.kind,
      periodKey: periodKey ?? this.periodKey,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (periodKey.present) {
      map['period_key'] = Variable<String>(periodKey.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiInsightsCompanion(')
          ..write('kind: $kind, ')
          ..write('periodKey: $periodKey, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MerchantCategoryCacheTable extends MerchantCategoryCache
    with TableInfo<$MerchantCategoryCacheTable, MerchantCategoryCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantCategoryCacheTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<int> confidence = GeneratedColumn<int>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _askedAtMeta = const VerificationMeta(
    'askedAt',
  );
  @override
  late final GeneratedColumn<DateTime> askedAt = GeneratedColumn<DateTime>(
    'asked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    canonical,
    category,
    confidence,
    askedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchant_category_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<MerchantCategoryCacheData> instance, {
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
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('asked_at')) {
      context.handle(
        _askedAtMeta,
        askedAt.isAcceptableOrUnknown(data['asked_at']!, _askedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_askedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {canonical};
  @override
  MerchantCategoryCacheData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchantCategoryCacheData(
      canonical: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confidence'],
      )!,
      askedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}asked_at'],
      )!,
    );
  }

  @override
  $MerchantCategoryCacheTable createAlias(String alias) {
    return $MerchantCategoryCacheTable(attachedDatabase, alias);
  }
}

class MerchantCategoryCacheData extends DataClass
    implements Insertable<MerchantCategoryCacheData> {
  final String canonical;
  final String category;

  /// The AI's own confidence (0–100) in this label.
  final int confidence;
  final DateTime askedAt;
  const MerchantCategoryCacheData({
    required this.canonical,
    required this.category,
    required this.confidence,
    required this.askedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['canonical'] = Variable<String>(canonical);
    map['category'] = Variable<String>(category);
    map['confidence'] = Variable<int>(confidence);
    map['asked_at'] = Variable<DateTime>(askedAt);
    return map;
  }

  MerchantCategoryCacheCompanion toCompanion(bool nullToAbsent) {
    return MerchantCategoryCacheCompanion(
      canonical: Value(canonical),
      category: Value(category),
      confidence: Value(confidence),
      askedAt: Value(askedAt),
    );
  }

  factory MerchantCategoryCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchantCategoryCacheData(
      canonical: serializer.fromJson<String>(json['canonical']),
      category: serializer.fromJson<String>(json['category']),
      confidence: serializer.fromJson<int>(json['confidence']),
      askedAt: serializer.fromJson<DateTime>(json['askedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'canonical': serializer.toJson<String>(canonical),
      'category': serializer.toJson<String>(category),
      'confidence': serializer.toJson<int>(confidence),
      'askedAt': serializer.toJson<DateTime>(askedAt),
    };
  }

  MerchantCategoryCacheData copyWith({
    String? canonical,
    String? category,
    int? confidence,
    DateTime? askedAt,
  }) => MerchantCategoryCacheData(
    canonical: canonical ?? this.canonical,
    category: category ?? this.category,
    confidence: confidence ?? this.confidence,
    askedAt: askedAt ?? this.askedAt,
  );
  MerchantCategoryCacheData copyWithCompanion(
    MerchantCategoryCacheCompanion data,
  ) {
    return MerchantCategoryCacheData(
      canonical: data.canonical.present ? data.canonical.value : this.canonical,
      category: data.category.present ? data.category.value : this.category,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      askedAt: data.askedAt.present ? data.askedAt.value : this.askedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchantCategoryCacheData(')
          ..write('canonical: $canonical, ')
          ..write('category: $category, ')
          ..write('confidence: $confidence, ')
          ..write('askedAt: $askedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(canonical, category, confidence, askedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchantCategoryCacheData &&
          other.canonical == this.canonical &&
          other.category == this.category &&
          other.confidence == this.confidence &&
          other.askedAt == this.askedAt);
}

class MerchantCategoryCacheCompanion
    extends UpdateCompanion<MerchantCategoryCacheData> {
  final Value<String> canonical;
  final Value<String> category;
  final Value<int> confidence;
  final Value<DateTime> askedAt;
  final Value<int> rowid;
  const MerchantCategoryCacheCompanion({
    this.canonical = const Value.absent(),
    this.category = const Value.absent(),
    this.confidence = const Value.absent(),
    this.askedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MerchantCategoryCacheCompanion.insert({
    required String canonical,
    required String category,
    required int confidence,
    required DateTime askedAt,
    this.rowid = const Value.absent(),
  }) : canonical = Value(canonical),
       category = Value(category),
       confidence = Value(confidence),
       askedAt = Value(askedAt);
  static Insertable<MerchantCategoryCacheData> custom({
    Expression<String>? canonical,
    Expression<String>? category,
    Expression<int>? confidence,
    Expression<DateTime>? askedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (canonical != null) 'canonical': canonical,
      if (category != null) 'category': category,
      if (confidence != null) 'confidence': confidence,
      if (askedAt != null) 'asked_at': askedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MerchantCategoryCacheCompanion copyWith({
    Value<String>? canonical,
    Value<String>? category,
    Value<int>? confidence,
    Value<DateTime>? askedAt,
    Value<int>? rowid,
  }) {
    return MerchantCategoryCacheCompanion(
      canonical: canonical ?? this.canonical,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      askedAt: askedAt ?? this.askedAt,
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
    if (confidence.present) {
      map['confidence'] = Variable<int>(confidence.value);
    }
    if (askedAt.present) {
      map['asked_at'] = Variable<DateTime>(askedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchantCategoryCacheCompanion(')
          ..write('canonical: $canonical, ')
          ..write('category: $category, ')
          ..write('confidence: $confidence, ')
          ..write('askedAt: $askedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseGoalsTable extends PurchaseGoals
    with TableInfo<$PurchaseGoalsTable, PurchaseGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseGoalsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedPriceMeta = const VerificationMeta(
    'estimatedPrice',
  );
  @override
  late final GeneratedColumn<double> estimatedPrice = GeneratedColumn<double>(
    'estimated_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedMeta = const VerificationMeta('saved');
  @override
  late final GeneratedColumn<double> saved = GeneratedColumn<double>(
    'saved',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _priceNoteMeta = const VerificationMeta(
    'priceNote',
  );
  @override
  late final GeneratedColumn<String> priceNote = GeneratedColumn<String>(
    'price_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    estimatedPrice,
    saved,
    priceNote,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('estimated_price')) {
      context.handle(
        _estimatedPriceMeta,
        estimatedPrice.isAcceptableOrUnknown(
          data['estimated_price']!,
          _estimatedPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedPriceMeta);
    }
    if (data.containsKey('saved')) {
      context.handle(
        _savedMeta,
        saved.isAcceptableOrUnknown(data['saved']!, _savedMeta),
      );
    }
    if (data.containsKey('price_note')) {
      context.handle(
        _priceNoteMeta,
        priceNote.isAcceptableOrUnknown(data['price_note']!, _priceNoteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      estimatedPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estimated_price'],
      )!,
      saved: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saved'],
      )!,
      priceNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PurchaseGoalsTable createAlias(String alias) {
    return $PurchaseGoalsTable(attachedDatabase, alias);
  }
}

class PurchaseGoal extends DataClass implements Insertable<PurchaseGoal> {
  final int id;
  final String name;
  final double estimatedPrice;
  final double saved;

  /// A short AI note about the estimate (model/segment/range), if any.
  final String? priceNote;
  final DateTime createdAt;
  const PurchaseGoal({
    required this.id,
    required this.name,
    required this.estimatedPrice,
    required this.saved,
    this.priceNote,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['estimated_price'] = Variable<double>(estimatedPrice);
    map['saved'] = Variable<double>(saved);
    if (!nullToAbsent || priceNote != null) {
      map['price_note'] = Variable<String>(priceNote);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PurchaseGoalsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseGoalsCompanion(
      id: Value(id),
      name: Value(name),
      estimatedPrice: Value(estimatedPrice),
      saved: Value(saved),
      priceNote: priceNote == null && nullToAbsent
          ? const Value.absent()
          : Value(priceNote),
      createdAt: Value(createdAt),
    );
  }

  factory PurchaseGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseGoal(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      estimatedPrice: serializer.fromJson<double>(json['estimatedPrice']),
      saved: serializer.fromJson<double>(json['saved']),
      priceNote: serializer.fromJson<String?>(json['priceNote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'estimatedPrice': serializer.toJson<double>(estimatedPrice),
      'saved': serializer.toJson<double>(saved),
      'priceNote': serializer.toJson<String?>(priceNote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PurchaseGoal copyWith({
    int? id,
    String? name,
    double? estimatedPrice,
    double? saved,
    Value<String?> priceNote = const Value.absent(),
    DateTime? createdAt,
  }) => PurchaseGoal(
    id: id ?? this.id,
    name: name ?? this.name,
    estimatedPrice: estimatedPrice ?? this.estimatedPrice,
    saved: saved ?? this.saved,
    priceNote: priceNote.present ? priceNote.value : this.priceNote,
    createdAt: createdAt ?? this.createdAt,
  );
  PurchaseGoal copyWithCompanion(PurchaseGoalsCompanion data) {
    return PurchaseGoal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      estimatedPrice: data.estimatedPrice.present
          ? data.estimatedPrice.value
          : this.estimatedPrice,
      saved: data.saved.present ? data.saved.value : this.saved,
      priceNote: data.priceNote.present ? data.priceNote.value : this.priceNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseGoal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('estimatedPrice: $estimatedPrice, ')
          ..write('saved: $saved, ')
          ..write('priceNote: $priceNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, estimatedPrice, saved, priceNote, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseGoal &&
          other.id == this.id &&
          other.name == this.name &&
          other.estimatedPrice == this.estimatedPrice &&
          other.saved == this.saved &&
          other.priceNote == this.priceNote &&
          other.createdAt == this.createdAt);
}

class PurchaseGoalsCompanion extends UpdateCompanion<PurchaseGoal> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> estimatedPrice;
  final Value<double> saved;
  final Value<String?> priceNote;
  final Value<DateTime> createdAt;
  const PurchaseGoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.estimatedPrice = const Value.absent(),
    this.saved = const Value.absent(),
    this.priceNote = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PurchaseGoalsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double estimatedPrice,
    this.saved = const Value.absent(),
    this.priceNote = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       estimatedPrice = Value(estimatedPrice),
       createdAt = Value(createdAt);
  static Insertable<PurchaseGoal> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? estimatedPrice,
    Expression<double>? saved,
    Expression<String>? priceNote,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (estimatedPrice != null) 'estimated_price': estimatedPrice,
      if (saved != null) 'saved': saved,
      if (priceNote != null) 'price_note': priceNote,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PurchaseGoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? estimatedPrice,
    Value<double>? saved,
    Value<String?>? priceNote,
    Value<DateTime>? createdAt,
  }) {
    return PurchaseGoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      saved: saved ?? this.saved,
      priceNote: priceNote ?? this.priceNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (estimatedPrice.present) {
      map['estimated_price'] = Variable<double>(estimatedPrice.value);
    }
    if (saved.present) {
      map['saved'] = Variable<double>(saved.value);
    }
    if (priceNote.present) {
      map['price_note'] = Variable<String>(priceNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseGoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('estimatedPrice: $estimatedPrice, ')
          ..write('saved: $saved, ')
          ..write('priceNote: $priceNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UnparsedMessagesTable extends UnparsedMessages
    with TableInfo<$UnparsedMessagesTable, UnparsedMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnparsedMessagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('needs_attention'),
  );
  static const VerificationMeta _aiAttemptsMeta = const VerificationMeta(
    'aiAttempts',
  );
  @override
  late final GeneratedColumn<int> aiAttempts = GeneratedColumn<int>(
    'ai_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    smsId,
    body,
    sender,
    receivedAt,
    reason,
    status,
    aiAttempts,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unparsed_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnparsedMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sms_id')) {
      context.handle(
        _smsIdMeta,
        smsId.isAcceptableOrUnknown(data['sms_id']!, _smsIdMeta),
      );
    } else if (isInserting) {
      context.missing(_smsIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('ai_attempts')) {
      context.handle(
        _aiAttemptsMeta,
        aiAttempts.isAcceptableOrUnknown(data['ai_attempts']!, _aiAttemptsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnparsedMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnparsedMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      smsId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sms_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      aiAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ai_attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UnparsedMessagesTable createAlias(String alias) {
    return $UnparsedMessagesTable(attachedDatabase, alias);
  }
}

class UnparsedMessage extends DataClass implements Insertable<UnparsedMessage> {
  final int id;

  /// Same stable id scheme as transactions, so re-scans don't duplicate.
  final String smsId;
  final String body;
  final String? sender;
  final DateTime receivedAt;

  /// 'needs_type' | 'needs_amount' | 'needs_structure'.
  final String reason;

  /// 'needs_attention' | 'ignored' (user/AI said not a txn) | 'resolved'.
  final String status;

  /// How many times opt-in AI parsing has been attempted (bounds retries).
  final int aiAttempts;
  final DateTime createdAt;
  const UnparsedMessage({
    required this.id,
    required this.smsId,
    required this.body,
    this.sender,
    required this.receivedAt,
    required this.reason,
    required this.status,
    required this.aiAttempts,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sms_id'] = Variable<String>(smsId);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || sender != null) {
      map['sender'] = Variable<String>(sender);
    }
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['reason'] = Variable<String>(reason);
    map['status'] = Variable<String>(status);
    map['ai_attempts'] = Variable<int>(aiAttempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UnparsedMessagesCompanion toCompanion(bool nullToAbsent) {
    return UnparsedMessagesCompanion(
      id: Value(id),
      smsId: Value(smsId),
      body: Value(body),
      sender: sender == null && nullToAbsent
          ? const Value.absent()
          : Value(sender),
      receivedAt: Value(receivedAt),
      reason: Value(reason),
      status: Value(status),
      aiAttempts: Value(aiAttempts),
      createdAt: Value(createdAt),
    );
  }

  factory UnparsedMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnparsedMessage(
      id: serializer.fromJson<int>(json['id']),
      smsId: serializer.fromJson<String>(json['smsId']),
      body: serializer.fromJson<String>(json['body']),
      sender: serializer.fromJson<String?>(json['sender']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      reason: serializer.fromJson<String>(json['reason']),
      status: serializer.fromJson<String>(json['status']),
      aiAttempts: serializer.fromJson<int>(json['aiAttempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'smsId': serializer.toJson<String>(smsId),
      'body': serializer.toJson<String>(body),
      'sender': serializer.toJson<String?>(sender),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'reason': serializer.toJson<String>(reason),
      'status': serializer.toJson<String>(status),
      'aiAttempts': serializer.toJson<int>(aiAttempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UnparsedMessage copyWith({
    int? id,
    String? smsId,
    String? body,
    Value<String?> sender = const Value.absent(),
    DateTime? receivedAt,
    String? reason,
    String? status,
    int? aiAttempts,
    DateTime? createdAt,
  }) => UnparsedMessage(
    id: id ?? this.id,
    smsId: smsId ?? this.smsId,
    body: body ?? this.body,
    sender: sender.present ? sender.value : this.sender,
    receivedAt: receivedAt ?? this.receivedAt,
    reason: reason ?? this.reason,
    status: status ?? this.status,
    aiAttempts: aiAttempts ?? this.aiAttempts,
    createdAt: createdAt ?? this.createdAt,
  );
  UnparsedMessage copyWithCompanion(UnparsedMessagesCompanion data) {
    return UnparsedMessage(
      id: data.id.present ? data.id.value : this.id,
      smsId: data.smsId.present ? data.smsId.value : this.smsId,
      body: data.body.present ? data.body.value : this.body,
      sender: data.sender.present ? data.sender.value : this.sender,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      reason: data.reason.present ? data.reason.value : this.reason,
      status: data.status.present ? data.status.value : this.status,
      aiAttempts: data.aiAttempts.present
          ? data.aiAttempts.value
          : this.aiAttempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnparsedMessage(')
          ..write('id: $id, ')
          ..write('smsId: $smsId, ')
          ..write('body: $body, ')
          ..write('sender: $sender, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('aiAttempts: $aiAttempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    smsId,
    body,
    sender,
    receivedAt,
    reason,
    status,
    aiAttempts,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnparsedMessage &&
          other.id == this.id &&
          other.smsId == this.smsId &&
          other.body == this.body &&
          other.sender == this.sender &&
          other.receivedAt == this.receivedAt &&
          other.reason == this.reason &&
          other.status == this.status &&
          other.aiAttempts == this.aiAttempts &&
          other.createdAt == this.createdAt);
}

class UnparsedMessagesCompanion extends UpdateCompanion<UnparsedMessage> {
  final Value<int> id;
  final Value<String> smsId;
  final Value<String> body;
  final Value<String?> sender;
  final Value<DateTime> receivedAt;
  final Value<String> reason;
  final Value<String> status;
  final Value<int> aiAttempts;
  final Value<DateTime> createdAt;
  const UnparsedMessagesCompanion({
    this.id = const Value.absent(),
    this.smsId = const Value.absent(),
    this.body = const Value.absent(),
    this.sender = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.aiAttempts = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UnparsedMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String smsId,
    required String body,
    this.sender = const Value.absent(),
    required DateTime receivedAt,
    required String reason,
    this.status = const Value.absent(),
    this.aiAttempts = const Value.absent(),
    required DateTime createdAt,
  }) : smsId = Value(smsId),
       body = Value(body),
       receivedAt = Value(receivedAt),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<UnparsedMessage> custom({
    Expression<int>? id,
    Expression<String>? smsId,
    Expression<String>? body,
    Expression<String>? sender,
    Expression<DateTime>? receivedAt,
    Expression<String>? reason,
    Expression<String>? status,
    Expression<int>? aiAttempts,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (smsId != null) 'sms_id': smsId,
      if (body != null) 'body': body,
      if (sender != null) 'sender': sender,
      if (receivedAt != null) 'received_at': receivedAt,
      if (reason != null) 'reason': reason,
      if (status != null) 'status': status,
      if (aiAttempts != null) 'ai_attempts': aiAttempts,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UnparsedMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? smsId,
    Value<String>? body,
    Value<String?>? sender,
    Value<DateTime>? receivedAt,
    Value<String>? reason,
    Value<String>? status,
    Value<int>? aiAttempts,
    Value<DateTime>? createdAt,
  }) {
    return UnparsedMessagesCompanion(
      id: id ?? this.id,
      smsId: smsId ?? this.smsId,
      body: body ?? this.body,
      sender: sender ?? this.sender,
      receivedAt: receivedAt ?? this.receivedAt,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      aiAttempts: aiAttempts ?? this.aiAttempts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (smsId.present) {
      map['sms_id'] = Variable<String>(smsId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (aiAttempts.present) {
      map['ai_attempts'] = Variable<int>(aiAttempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnparsedMessagesCompanion(')
          ..write('id: $id, ')
          ..write('smsId: $smsId, ')
          ..write('body: $body, ')
          ..write('sender: $sender, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('aiAttempts: $aiAttempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MerchantAliasesTable extends MerchantAliases
    with TableInfo<$MerchantAliasesTable, MerchantAliase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantAliasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  List<GeneratedColumn> get $columns => [alias, canonical, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchant_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<MerchantAliase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('canonical')) {
      context.handle(
        _canonicalMeta,
        canonical.isAcceptableOrUnknown(data['canonical']!, _canonicalMeta),
      );
    } else if (isInserting) {
      context.missing(_canonicalMeta);
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
  Set<GeneratedColumn> get $primaryKey => {alias};
  @override
  MerchantAliase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchantAliase(
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      canonical: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $MerchantAliasesTable createAlias(String alias) {
    return $MerchantAliasesTable(attachedDatabase, alias);
  }
}

class MerchantAliase extends DataClass implements Insertable<MerchantAliase> {
  /// The raw string as seen in SMS, lowercased.
  final String alias;
  final String canonical;

  /// 'user' | 'ai'.
  final String source;
  const MerchantAliase({
    required this.alias,
    required this.canonical,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['alias'] = Variable<String>(alias);
    map['canonical'] = Variable<String>(canonical);
    map['source'] = Variable<String>(source);
    return map;
  }

  MerchantAliasesCompanion toCompanion(bool nullToAbsent) {
    return MerchantAliasesCompanion(
      alias: Value(alias),
      canonical: Value(canonical),
      source: Value(source),
    );
  }

  factory MerchantAliase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchantAliase(
      alias: serializer.fromJson<String>(json['alias']),
      canonical: serializer.fromJson<String>(json['canonical']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'alias': serializer.toJson<String>(alias),
      'canonical': serializer.toJson<String>(canonical),
      'source': serializer.toJson<String>(source),
    };
  }

  MerchantAliase copyWith({String? alias, String? canonical, String? source}) =>
      MerchantAliase(
        alias: alias ?? this.alias,
        canonical: canonical ?? this.canonical,
        source: source ?? this.source,
      );
  MerchantAliase copyWithCompanion(MerchantAliasesCompanion data) {
    return MerchantAliase(
      alias: data.alias.present ? data.alias.value : this.alias,
      canonical: data.canonical.present ? data.canonical.value : this.canonical,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchantAliase(')
          ..write('alias: $alias, ')
          ..write('canonical: $canonical, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(alias, canonical, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchantAliase &&
          other.alias == this.alias &&
          other.canonical == this.canonical &&
          other.source == this.source);
}

class MerchantAliasesCompanion extends UpdateCompanion<MerchantAliase> {
  final Value<String> alias;
  final Value<String> canonical;
  final Value<String> source;
  final Value<int> rowid;
  const MerchantAliasesCompanion({
    this.alias = const Value.absent(),
    this.canonical = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MerchantAliasesCompanion.insert({
    required String alias,
    required String canonical,
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : alias = Value(alias),
       canonical = Value(canonical);
  static Insertable<MerchantAliase> custom({
    Expression<String>? alias,
    Expression<String>? canonical,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (alias != null) 'alias': alias,
      if (canonical != null) 'canonical': canonical,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MerchantAliasesCompanion copyWith({
    Value<String>? alias,
    Value<String>? canonical,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return MerchantAliasesCompanion(
      alias: alias ?? this.alias,
      canonical: canonical ?? this.canonical,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (canonical.present) {
      map['canonical'] = Variable<String>(canonical.value);
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
    return (StringBuffer('MerchantAliasesCompanion(')
          ..write('alias: $alias, ')
          ..write('canonical: $canonical, ')
          ..write('source: $source, ')
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
  late final $AiInsightsTable aiInsights = $AiInsightsTable(this);
  late final $MerchantCategoryCacheTable merchantCategoryCache =
      $MerchantCategoryCacheTable(this);
  late final $PurchaseGoalsTable purchaseGoals = $PurchaseGoalsTable(this);
  late final $UnparsedMessagesTable unparsedMessages = $UnparsedMessagesTable(
    this,
  );
  late final $MerchantAliasesTable merchantAliases = $MerchantAliasesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    merchantMemories,
    budgets,
    alertLogs,
    aiInsights,
    merchantCategoryCache,
    purchaseGoals,
    unparsedMessages,
    merchantAliases,
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
typedef $$AiInsightsTableCreateCompanionBuilder =
    AiInsightsCompanion Function({
      required String kind,
      required String periodKey,
      required String content,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AiInsightsTableUpdateCompanionBuilder =
    AiInsightsCompanion Function({
      Value<String> kind,
      Value<String> periodKey,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AiInsightsTableFilterComposer
    extends Composer<_$AppDatabase, $AiInsightsTable> {
  $$AiInsightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiInsightsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiInsightsTable> {
  $$AiInsightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodKey => $composableBuilder(
    column: $table.periodKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiInsightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiInsightsTable> {
  $$AiInsightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get periodKey =>
      $composableBuilder(column: $table.periodKey, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AiInsightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiInsightsTable,
          AiInsight,
          $$AiInsightsTableFilterComposer,
          $$AiInsightsTableOrderingComposer,
          $$AiInsightsTableAnnotationComposer,
          $$AiInsightsTableCreateCompanionBuilder,
          $$AiInsightsTableUpdateCompanionBuilder,
          (
            AiInsight,
            BaseReferences<_$AppDatabase, $AiInsightsTable, AiInsight>,
          ),
          AiInsight,
          PrefetchHooks Function()
        > {
  $$AiInsightsTableTableManager(_$AppDatabase db, $AiInsightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiInsightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiInsightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiInsightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> kind = const Value.absent(),
                Value<String> periodKey = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiInsightsCompanion(
                kind: kind,
                periodKey: periodKey,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String kind,
                required String periodKey,
                required String content,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AiInsightsCompanion.insert(
                kind: kind,
                periodKey: periodKey,
                content: content,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiInsightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiInsightsTable,
      AiInsight,
      $$AiInsightsTableFilterComposer,
      $$AiInsightsTableOrderingComposer,
      $$AiInsightsTableAnnotationComposer,
      $$AiInsightsTableCreateCompanionBuilder,
      $$AiInsightsTableUpdateCompanionBuilder,
      (AiInsight, BaseReferences<_$AppDatabase, $AiInsightsTable, AiInsight>),
      AiInsight,
      PrefetchHooks Function()
    >;
typedef $$MerchantCategoryCacheTableCreateCompanionBuilder =
    MerchantCategoryCacheCompanion Function({
      required String canonical,
      required String category,
      required int confidence,
      required DateTime askedAt,
      Value<int> rowid,
    });
typedef $$MerchantCategoryCacheTableUpdateCompanionBuilder =
    MerchantCategoryCacheCompanion Function({
      Value<String> canonical,
      Value<String> category,
      Value<int> confidence,
      Value<DateTime> askedAt,
      Value<int> rowid,
    });

class $$MerchantCategoryCacheTableFilterComposer
    extends Composer<_$AppDatabase, $MerchantCategoryCacheTable> {
  $$MerchantCategoryCacheTableFilterComposer({
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

  ColumnFilters<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get askedAt => $composableBuilder(
    column: $table.askedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MerchantCategoryCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchantCategoryCacheTable> {
  $$MerchantCategoryCacheTableOrderingComposer({
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

  ColumnOrderings<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get askedAt => $composableBuilder(
    column: $table.askedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MerchantCategoryCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchantCategoryCacheTable> {
  $$MerchantCategoryCacheTableAnnotationComposer({
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

  GeneratedColumn<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get askedAt =>
      $composableBuilder(column: $table.askedAt, builder: (column) => column);
}

class $$MerchantCategoryCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MerchantCategoryCacheTable,
          MerchantCategoryCacheData,
          $$MerchantCategoryCacheTableFilterComposer,
          $$MerchantCategoryCacheTableOrderingComposer,
          $$MerchantCategoryCacheTableAnnotationComposer,
          $$MerchantCategoryCacheTableCreateCompanionBuilder,
          $$MerchantCategoryCacheTableUpdateCompanionBuilder,
          (
            MerchantCategoryCacheData,
            BaseReferences<
              _$AppDatabase,
              $MerchantCategoryCacheTable,
              MerchantCategoryCacheData
            >,
          ),
          MerchantCategoryCacheData,
          PrefetchHooks Function()
        > {
  $$MerchantCategoryCacheTableTableManager(
    _$AppDatabase db,
    $MerchantCategoryCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantCategoryCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MerchantCategoryCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MerchantCategoryCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> canonical = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> confidence = const Value.absent(),
                Value<DateTime> askedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MerchantCategoryCacheCompanion(
                canonical: canonical,
                category: category,
                confidence: confidence,
                askedAt: askedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String canonical,
                required String category,
                required int confidence,
                required DateTime askedAt,
                Value<int> rowid = const Value.absent(),
              }) => MerchantCategoryCacheCompanion.insert(
                canonical: canonical,
                category: category,
                confidence: confidence,
                askedAt: askedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MerchantCategoryCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MerchantCategoryCacheTable,
      MerchantCategoryCacheData,
      $$MerchantCategoryCacheTableFilterComposer,
      $$MerchantCategoryCacheTableOrderingComposer,
      $$MerchantCategoryCacheTableAnnotationComposer,
      $$MerchantCategoryCacheTableCreateCompanionBuilder,
      $$MerchantCategoryCacheTableUpdateCompanionBuilder,
      (
        MerchantCategoryCacheData,
        BaseReferences<
          _$AppDatabase,
          $MerchantCategoryCacheTable,
          MerchantCategoryCacheData
        >,
      ),
      MerchantCategoryCacheData,
      PrefetchHooks Function()
    >;
typedef $$PurchaseGoalsTableCreateCompanionBuilder =
    PurchaseGoalsCompanion Function({
      Value<int> id,
      required String name,
      required double estimatedPrice,
      Value<double> saved,
      Value<String?> priceNote,
      required DateTime createdAt,
    });
typedef $$PurchaseGoalsTableUpdateCompanionBuilder =
    PurchaseGoalsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> estimatedPrice,
      Value<double> saved,
      Value<String?> priceNote,
      Value<DateTime> createdAt,
    });

class $$PurchaseGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseGoalsTable> {
  $$PurchaseGoalsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estimatedPrice => $composableBuilder(
    column: $table.estimatedPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saved => $composableBuilder(
    column: $table.saved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceNote => $composableBuilder(
    column: $table.priceNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PurchaseGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseGoalsTable> {
  $$PurchaseGoalsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estimatedPrice => $composableBuilder(
    column: $table.estimatedPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saved => $composableBuilder(
    column: $table.saved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceNote => $composableBuilder(
    column: $table.priceNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurchaseGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseGoalsTable> {
  $$PurchaseGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get estimatedPrice => $composableBuilder(
    column: $table.estimatedPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get saved =>
      $composableBuilder(column: $table.saved, builder: (column) => column);

  GeneratedColumn<String> get priceNote =>
      $composableBuilder(column: $table.priceNote, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PurchaseGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseGoalsTable,
          PurchaseGoal,
          $$PurchaseGoalsTableFilterComposer,
          $$PurchaseGoalsTableOrderingComposer,
          $$PurchaseGoalsTableAnnotationComposer,
          $$PurchaseGoalsTableCreateCompanionBuilder,
          $$PurchaseGoalsTableUpdateCompanionBuilder,
          (
            PurchaseGoal,
            BaseReferences<_$AppDatabase, $PurchaseGoalsTable, PurchaseGoal>,
          ),
          PurchaseGoal,
          PrefetchHooks Function()
        > {
  $$PurchaseGoalsTableTableManager(_$AppDatabase db, $PurchaseGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> estimatedPrice = const Value.absent(),
                Value<double> saved = const Value.absent(),
                Value<String?> priceNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PurchaseGoalsCompanion(
                id: id,
                name: name,
                estimatedPrice: estimatedPrice,
                saved: saved,
                priceNote: priceNote,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double estimatedPrice,
                Value<double> saved = const Value.absent(),
                Value<String?> priceNote = const Value.absent(),
                required DateTime createdAt,
              }) => PurchaseGoalsCompanion.insert(
                id: id,
                name: name,
                estimatedPrice: estimatedPrice,
                saved: saved,
                priceNote: priceNote,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurchaseGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseGoalsTable,
      PurchaseGoal,
      $$PurchaseGoalsTableFilterComposer,
      $$PurchaseGoalsTableOrderingComposer,
      $$PurchaseGoalsTableAnnotationComposer,
      $$PurchaseGoalsTableCreateCompanionBuilder,
      $$PurchaseGoalsTableUpdateCompanionBuilder,
      (
        PurchaseGoal,
        BaseReferences<_$AppDatabase, $PurchaseGoalsTable, PurchaseGoal>,
      ),
      PurchaseGoal,
      PrefetchHooks Function()
    >;
typedef $$UnparsedMessagesTableCreateCompanionBuilder =
    UnparsedMessagesCompanion Function({
      Value<int> id,
      required String smsId,
      required String body,
      Value<String?> sender,
      required DateTime receivedAt,
      required String reason,
      Value<String> status,
      Value<int> aiAttempts,
      required DateTime createdAt,
    });
typedef $$UnparsedMessagesTableUpdateCompanionBuilder =
    UnparsedMessagesCompanion Function({
      Value<int> id,
      Value<String> smsId,
      Value<String> body,
      Value<String?> sender,
      Value<DateTime> receivedAt,
      Value<String> reason,
      Value<String> status,
      Value<int> aiAttempts,
      Value<DateTime> createdAt,
    });

class $$UnparsedMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $UnparsedMessagesTable> {
  $$UnparsedMessagesTableFilterComposer({
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

  ColumnFilters<String> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aiAttempts => $composableBuilder(
    column: $table.aiAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnparsedMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $UnparsedMessagesTable> {
  $$UnparsedMessagesTableOrderingComposer({
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

  ColumnOrderings<String> get smsId => $composableBuilder(
    column: $table.smsId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aiAttempts => $composableBuilder(
    column: $table.aiAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnparsedMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnparsedMessagesTable> {
  $$UnparsedMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get smsId =>
      $composableBuilder(column: $table.smsId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get aiAttempts => $composableBuilder(
    column: $table.aiAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UnparsedMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnparsedMessagesTable,
          UnparsedMessage,
          $$UnparsedMessagesTableFilterComposer,
          $$UnparsedMessagesTableOrderingComposer,
          $$UnparsedMessagesTableAnnotationComposer,
          $$UnparsedMessagesTableCreateCompanionBuilder,
          $$UnparsedMessagesTableUpdateCompanionBuilder,
          (
            UnparsedMessage,
            BaseReferences<
              _$AppDatabase,
              $UnparsedMessagesTable,
              UnparsedMessage
            >,
          ),
          UnparsedMessage,
          PrefetchHooks Function()
        > {
  $$UnparsedMessagesTableTableManager(
    _$AppDatabase db,
    $UnparsedMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnparsedMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnparsedMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnparsedMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> smsId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> sender = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> aiAttempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UnparsedMessagesCompanion(
                id: id,
                smsId: smsId,
                body: body,
                sender: sender,
                receivedAt: receivedAt,
                reason: reason,
                status: status,
                aiAttempts: aiAttempts,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String smsId,
                required String body,
                Value<String?> sender = const Value.absent(),
                required DateTime receivedAt,
                required String reason,
                Value<String> status = const Value.absent(),
                Value<int> aiAttempts = const Value.absent(),
                required DateTime createdAt,
              }) => UnparsedMessagesCompanion.insert(
                id: id,
                smsId: smsId,
                body: body,
                sender: sender,
                receivedAt: receivedAt,
                reason: reason,
                status: status,
                aiAttempts: aiAttempts,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnparsedMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnparsedMessagesTable,
      UnparsedMessage,
      $$UnparsedMessagesTableFilterComposer,
      $$UnparsedMessagesTableOrderingComposer,
      $$UnparsedMessagesTableAnnotationComposer,
      $$UnparsedMessagesTableCreateCompanionBuilder,
      $$UnparsedMessagesTableUpdateCompanionBuilder,
      (
        UnparsedMessage,
        BaseReferences<_$AppDatabase, $UnparsedMessagesTable, UnparsedMessage>,
      ),
      UnparsedMessage,
      PrefetchHooks Function()
    >;
typedef $$MerchantAliasesTableCreateCompanionBuilder =
    MerchantAliasesCompanion Function({
      required String alias,
      required String canonical,
      Value<String> source,
      Value<int> rowid,
    });
typedef $$MerchantAliasesTableUpdateCompanionBuilder =
    MerchantAliasesCompanion Function({
      Value<String> alias,
      Value<String> canonical,
      Value<String> source,
      Value<int> rowid,
    });

class $$MerchantAliasesTableFilterComposer
    extends Composer<_$AppDatabase, $MerchantAliasesTable> {
  $$MerchantAliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonical => $composableBuilder(
    column: $table.canonical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MerchantAliasesTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchantAliasesTable> {
  $$MerchantAliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonical => $composableBuilder(
    column: $table.canonical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MerchantAliasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchantAliasesTable> {
  $$MerchantAliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get canonical =>
      $composableBuilder(column: $table.canonical, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$MerchantAliasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MerchantAliasesTable,
          MerchantAliase,
          $$MerchantAliasesTableFilterComposer,
          $$MerchantAliasesTableOrderingComposer,
          $$MerchantAliasesTableAnnotationComposer,
          $$MerchantAliasesTableCreateCompanionBuilder,
          $$MerchantAliasesTableUpdateCompanionBuilder,
          (
            MerchantAliase,
            BaseReferences<
              _$AppDatabase,
              $MerchantAliasesTable,
              MerchantAliase
            >,
          ),
          MerchantAliase,
          PrefetchHooks Function()
        > {
  $$MerchantAliasesTableTableManager(
    _$AppDatabase db,
    $MerchantAliasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantAliasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchantAliasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchantAliasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> alias = const Value.absent(),
                Value<String> canonical = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MerchantAliasesCompanion(
                alias: alias,
                canonical: canonical,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String alias,
                required String canonical,
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MerchantAliasesCompanion.insert(
                alias: alias,
                canonical: canonical,
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

typedef $$MerchantAliasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MerchantAliasesTable,
      MerchantAliase,
      $$MerchantAliasesTableFilterComposer,
      $$MerchantAliasesTableOrderingComposer,
      $$MerchantAliasesTableAnnotationComposer,
      $$MerchantAliasesTableCreateCompanionBuilder,
      $$MerchantAliasesTableUpdateCompanionBuilder,
      (
        MerchantAliase,
        BaseReferences<_$AppDatabase, $MerchantAliasesTable, MerchantAliase>,
      ),
      MerchantAliase,
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
  $$AiInsightsTableTableManager get aiInsights =>
      $$AiInsightsTableTableManager(_db, _db.aiInsights);
  $$MerchantCategoryCacheTableTableManager get merchantCategoryCache =>
      $$MerchantCategoryCacheTableTableManager(_db, _db.merchantCategoryCache);
  $$PurchaseGoalsTableTableManager get purchaseGoals =>
      $$PurchaseGoalsTableTableManager(_db, _db.purchaseGoals);
  $$UnparsedMessagesTableTableManager get unparsedMessages =>
      $$UnparsedMessagesTableTableManager(_db, _db.unparsedMessages);
  $$MerchantAliasesTableTableManager get merchantAliases =>
      $$MerchantAliasesTableTableManager(_db, _db.merchantAliases);
}
