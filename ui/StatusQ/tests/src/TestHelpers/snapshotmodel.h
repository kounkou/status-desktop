#pragma once

#include <QAbstractListModel>

class SnapshotModel : public QAbstractListModel {

public:
    explicit SnapshotModel(QObject* parent = nullptr);
    explicit SnapshotModel(const QAbstractItemModel& model, bool recursive = true,
                           QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = {}) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex& index, int role) const override;

    void grabSnapshot(const QAbstractItemModel& model, bool recursive = true);
    QVariant data(int row, int role) const;

private:
    QHash<int, QList<QVariant>> m_data;
    QHash<int, QByteArray> m_roles;
};
