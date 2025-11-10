-- CreateEnum
CREATE TYPE "PlannerPriority" AS ENUM ('BAJA', 'MEDIA', 'ALTA');

-- CreateEnum
CREATE TYPE "PlannerDifficulty" AS ENUM ('FACIL', 'INTERMEDIA', 'DIFICIL');

-- CreateTable
CREATE TABLE "PlannerActivity" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "title" TEXT NOT NULL,
    "durationMin" INTEGER NOT NULL,
    "priority" "PlannerPriority" NOT NULL,
    "difficulty" "PlannerDifficulty" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PlannerActivity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PlannerCommit" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "version" TEXT NOT NULL,
    "blocks" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PlannerCommit_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "PlannerActivity_userId_date_idx" ON "PlannerActivity"("userId", "date");

-- CreateIndex
CREATE INDEX "PlannerCommit_userId_date_idx" ON "PlannerCommit"("userId", "date");
