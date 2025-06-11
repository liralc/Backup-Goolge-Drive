import React, { useState, useEffect } from "react";
import { ApiResponse } from "../types/data";
import { Search, Filter, RefreshCw, ShieldCheck } from "lucide-react";
import { useThemeStore } from "../store/themeStore";
import { useNavigate } from "react-router-dom";
import IpFilterDialog, { IFilterIPList } from "./IpFilterDialog";
import { DateFilterDialog } from "@/components/DateFilterDialog";
import { ActionButton } from "@/components/ActionButton";
import DeviceCard from "./DeviceCard";
import DeviceCardNoData from "./DeviceCardNoData";
import { X } from "lucide-react";
import { DeviceFilterDialog } from "./DevicesFilterDialog";

type Props = {
  data: ApiResponse[];
  onFilterDevice: (f: IFilterIPList) => void;
  onRefresh: (ip: string, isSourceIp: boolean, id: string) => void;
  loadingProcess: boolean;
};

export const DeviceList: React.FC<Props> = ({
  data,
  onFilterDevice,
  onRefresh,
  loadingProcess,
}) => {
  const { isDarkMode } = useThemeStore();
  const [isFilterDialogOpen, setIsFilterDialogOpen] = useState(false);
  const [isDateFilterDialogOpen, setIsDateFilterDialogOpen] = useState(false);
  const [isDeviceFilterDialogOpen, setIsDeviceFilterDialogOpen] = useState(false);
  const [selectedIp, setSelectedIp] = useState<string>(data[0]?.ip || "");
  const [fadeFilter, setFadeFilter] = useState(false);
  const [fadeDate, setFadeDate] = useState(false);

  const navigate = useNavigate();

  const availableIps = Array.from(new Set(data.map((d) => d.ip)));
  const selectedData = data.find((d) => d.ip === selectedIp);

  useEffect(() => {
    if (!data.some((d) => d.ip === selectedIp)) {
      setSelectedIp(data[0]?.ip || "");
    }
  }, [data, selectedIp]);

  const handleSearchDevices = () => {
    setFadeFilter(false);
    setTimeout(() => {
      setIsDeviceFilterDialogOpen(true);
      setTimeout(() => setFadeFilter(true), 10);
    }, 180);
  };

  const handleSearchClick = () => {
    setFadeFilter(false);
    setTimeout(() => {
      setIsFilterDialogOpen(true);
      setTimeout(() => setFadeFilter(true), 10); // ativa o fade logo após abrir
    }, 180);
  };

  const handleFilterClick = () => {
    setFadeDate(false);
    setTimeout(() => {
      setIsDateFilterDialogOpen(true);
      setTimeout(() => setFadeDate(true), 10);
    }, 180);
  };

  const handleRefresh = (ip: string, isSourceIp: boolean, id: string) => {
    setTimeout(() => {
      onRefresh(ip, isSourceIp, id);
    }, 180);
  };

  if (data.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] p-6">
        <div className="flex flex-col items-center">
          <div
            className={`rounded-full p-6 mb-4 shadow-xl ${
              isDarkMode ? "bg-blue-950" : "bg-blue-100"
            }`}
          >
            <ShieldCheck
              className={`w-16 h-16 ${
                isDarkMode ? "text-blue-400" : "text-blue-600"
              }`}
            />
          </div>
          <h1
            className={`text-4xl font-extrabold mb-2 text-center ${
              isDarkMode ? "text-white" : "text-gray-900"
            }`}
          >
            Nenhum dispositivo encontrado
          </h1>
          <p
            className={`text-lg mb-8 text-center max-w-lg ${
              isDarkMode ? "text-gray-300" : "text-gray-600"
            }`}
          >
            Nenhum FlowSpec foi localizado.
            <br />
            Inicie uma inspeção para encontrar dispositivos e analisar as regras
            aplicadas no device.
          </p>
          <div className="flex gap-4 mb-4">
            <ActionButton
              onClick={handleSearchDevices}
              icon={<Search className="w-5 h-5" />}
            >
              Buscar Ip e Devices
            </ActionButton>
            <ActionButton
              onClick={handleSearchClick}
              icon={<Search className="w-5 h-5" />}
            >
              Buscar por IP
            </ActionButton>
            <ActionButton
              onClick={handleFilterClick}
              icon={<Filter className="w-5 h-5" />}
            >
              Filtrar por Data
            </ActionButton>
          </div>
          <span
            className={`text-sm ${
              isDarkMode ? "text-gray-400" : "text-gray-500"
            }`}
          >
            Dica: utilize os filtros para refinar sua busca por inspeções e
            regras!
          </span>
        </div>

        <DeviceFilterDialog
          isOpen={isDeviceFilterDialogOpen}
          onClose={() => setIsDeviceFilterDialogOpen(false)}
          onFilterDevice={onFilterDevice}
          className={`${
            fadeDate ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4"
          } transition-all duration-300`}
        />

        <IpFilterDialog
          isOpen={isFilterDialogOpen}
          onClose={() => setIsFilterDialogOpen(false)}
          onFilterIP={onFilterDevice}
          className={`${
            fadeFilter ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4"
          } transition-all duration-300`}
        />

        <DateFilterDialog
          isOpen={isDateFilterDialogOpen}
          onClose={() => setIsDateFilterDialogOpen(false)}
          onFilterDate={(filters) => {
            navigate("/filter", { state: { filters } });
          }}
          className={`${
            fadeDate ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4"
          } transition-all duration-300`}
        />
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <ShieldCheck
            className={`w-6 h-6 ${
              isDarkMode ? "text-blue-400" : "text-blue-600"
            }`}
          />
          <h2
            className={`text-xl font-bold ${
              isDarkMode ? "text-white" : "text-gray-900"
            }`}
          >
            FlowSpec
          </h2>
        </div>
        <div className="flex gap-2">
          <ActionButton
            onClick={handleSearchDevices}
            icon={<Search className="w-5 h-5" />}
          >
            Buscar Ip e Devices
          </ActionButton>
          <ActionButton
            onClick={handleFilterClick}
            icon={<Filter className="w-5 h-5" />}
          >
            Filtrar por Data
          </ActionButton>
          <ActionButton
            onClick={handleSearchClick}
            icon={<Search className="w-5 h-5" />}
          >
            Buscar por IP
          </ActionButton>
        </div>
      </div>

      <div className="mb-6">
        <div className="flex flex-wrap gap-3 items-center">
          {availableIps.map((ip) => (
            <div key={ip} className="relative flex items-center">
              <button
                onClick={() => setSelectedIp(ip)}
                className={`
          px-6 py-2 rounded-full font-medium text-sm shadow transition-all duration-200
          border-2
          ${
            ip === selectedIp
              ? isDarkMode
                ? "bg-blue-900/80 border-blue-400 text-blue-200 shadow-lg scale-105"
                : "bg-blue-100 border-blue-600 text-blue-700 shadow-lg scale-105"
              : isDarkMode
              ? "bg-gray-800 border-gray-700 text-gray-400 hover:bg-blue-950/40 hover:text-blue-300"
              : "bg-white border-gray-200 text-gray-500 hover:bg-blue-50 hover:text-blue-600"
          }
          hover:scale-105
        `}
                style={{ minWidth: 120 }}
              >
                {ip}
              </button>
              <button
                onClick={() => {
                  // Remove o IP da lista (você pode adaptar para sua lógica)
                  // Exemplo: dispatch para remover IP do filtro ou atualizar o estado do pai
                }}
                className="absolute -top--1 -right-0 bg-gray-500 hover:bg-gray-600 text-white rounded-full p-1 shadow transition hover:scale-90"
                title="Fechar aba"
                style={{ lineHeight: 0 }}
              >
                <X className="w-2 h-2" />
              </button>
            </div>
          ))}
        </div>
        {selectedData && (
          <div className="flex items-center justify-between mt-4">
            <div
              className={`${isDarkMode ? "text-gray-300" : "text-gray-600"}`}
            >
              Data: {selectedData.date} - {selectedData.hour}
            </div>
            <button
              onClick={() =>
                handleRefresh(
                  selectedData.ip,
                  selectedData.is_src_ip,
                  selectedData.id
                )
              }
              className={`flex items-center gap-2 px-3 py-1 rounded ${
                isDarkMode
                  ? "bg-gray-700 text-gray-300 hover:bg-gray-600"
                  : "bg-gray-100 text-gray-700 hover:bg-gray-200"
              } ${loadingProcess ? "opacity-60 cursor-not-allowed" : ""}`}
              disabled={loadingProcess}
            >
              {loadingProcess ? (
                <>
                  <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24">
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                      fill="none"
                    />
                    <path
                      className="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8v4l3-3-3-3v4a8 8 0 00-8 8h4z"
                    />
                  </svg>
                  Processando...
                </>
              ) : (
                <>
                  <RefreshCw className="w-4 h-4" />
                  Buscar Incrementos
                </>
              )}
            </button>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {selectedData?.devices.map((device, idx) =>
          "matches" in device.data ? (
            <DeviceCard
              key={`${selectedData.ip}-${device.data.entry_id}-${idx}`}
              device={device}
              isDarkMode={isDarkMode}
              ip={selectedData.id}
            />
          ) : (
            <DeviceCardNoData
              key={`${selectedData.ip}-${device.data.device}-${idx}`}
              device={device}
              isDarkMode={isDarkMode}
            />
          )
        )}
      </div>

      <DeviceFilterDialog
        isOpen={isDeviceFilterDialogOpen}
        onClose={() => setIsDeviceFilterDialogOpen(false)}
        onFilterDevice={onFilterDevice}
        className={`${
          fadeDate ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4"
        } transition-all duration-300`} // fade-in
      />

      <IpFilterDialog
        isOpen={isFilterDialogOpen}
        onClose={() => setIsFilterDialogOpen(false)}
        onFilterIP={onFilterDevice}
        className={`${
          fadeFilter ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4"
        } transition-all duration-300`} // fade-in
      />

      <DateFilterDialog
        isOpen={isDateFilterDialogOpen}
        onClose={() => setIsDateFilterDialogOpen(false)}
        onFilterDate={(filters) => {
          navigate("/filter", { state: { filters } });
        }}
        className={`${
          fadeDate ? "opacity-100 translate-y-0" : "opacity-0 translate-y-4"
        } transition-all duration-300`} // fade-in
      />
    </div>
  );
};


================================================


import React, { useState } from 'react';
import { Cpu } from 'lucide-react';
import FlipCard from './FlipCard';

type DeviceCardProps = {
  device: any;
  isDarkMode: boolean;
  ip: string;
};

const DeviceCard: React.FC<DeviceCardProps> = ({ device, isDarkMode, ip }) => {
  const [flipped, setFlipped] = useState(false);

  return (
    <FlipCard
      isDarkMode={isDarkMode}
      front={
        <>
          <div className="flex justify-between items-start mb-4">
            <h3 className={`flex items-center gap-2 text-lg font-bold tracking-wide ${isDarkMode ? 'text-white' : 'text-blue-900'}`}>
              <Cpu className="w-5 h-5 opacity-70" />
              {device.data.device}
            </h3>
            <span
              className={`
                px-2 py-0.5 rounded-full text-sm font-semibold shadow
                ${device.data.isIncrement
                  ? 'bg-green-100 text-green-800'
                  : 'bg-yellow-200 text-yellow-900 animate-pulse font-extrabold border border-yellow-400 ring-2 ring-yellow-300/40'
                }
                transition-all duration-300
              `}
              style={device.data.isIncrement ? {} : { animationDuration: '0.8s' }}
            >
              {device.data.isIncrement ? 'Incremento' : 'Sem Incremento!'}
            </span>
          </div>
          <div className="grid grid-cols-2 gap-4 mb-4">
            <div>
              <p className={`text-xs font-semibold uppercase ${isDarkMode ? 'text-blue-300' : 'text-blue-700'}`}>ID</p>
              <p className={`text-sm mb-1 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>{device.data.entry_id}</p>
              <p className={`text-xs font-semibold uppercase ${isDarkMode ? 'text-blue-300' : 'text-blue-700'}`}>Sequência</p>
              <p className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>{device.data.sequence}</p>
            </div>
            <div>
              <p className={`text-xs font-semibold uppercase ${isDarkMode ? 'text-blue-300' : 'text-blue-700'}`}>IP Origem</p>
              <p className={`text-sm mb-1 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>{device.data.src_ip}</p>
              <p className={`text-xs font-semibold uppercase ${isDarkMode ? 'text-blue-300' : 'text-blue-700'}`}>IP Destino</p>
              <p className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>{device.data.dest_ip}</p>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-6">
            <div>
              <h4 className={`font-semibold mb-2 ${isDarkMode ? 'text-blue-200' : 'text-blue-900'}`}>Match Um</h4>
              <div className={`${isDarkMode ? 'bg-gray-700/70' : 'bg-blue-50'} p-3 rounded-lg`}>
                <div className="mb-2">
                  <p className={`text-xs font-bold ${isDarkMode ? 'text-blue-300' : 'text-blue-700'}`}>Entrada</p>
                  <p className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>Pacotes: {device.data.matches.matcheOne.ingress.packets}</p>
                  <p className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>Bytes: {device.data.matches.matcheOne.ingress.bytes || 0}</p>
                </div>
                <div>
                  <p className={`text-xs font-bold ${isDarkMode ? 'text-blue-300' : 'text-blue-700'}`}>Saída</p>
                  <p className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>Pacotes: {device.data.matches.matcheOne.egress.packets}</p>
                  <p className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>Bytes: {device.data.matches.matcheOne.egress.bytes || 0}</p>
                </div>
              </div>
            </div>
            <div>
              <h4 className={`font-semibold mb-2 ${isDarkMode ? 'text-blue-200' : 'text-blue-900'}`}>Match Dois</h4>
              <div className={`${isDarkMode ? 'bg-gray-700/70' : 'bg-blue-50'} p-3 rounded-lg`}>
                <div className="mb-2">
                  <p className={`text-xs font-bold ${isDarkMode ? 'text-blue-300' : 'text-blue-700'}`}>Entrada</p>
                  <p className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>Pacotes: {device.data.matches.matcheTwo.ingress.packets}</p>
                  <p className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>Bytes: {device.data.matches.matcheTwo.ingress.bytes}</p>
                </div>
                <div>
                  <p className={`text-xs font-bold ${isDarkMode ? 'text-blue-300' : 'text-blue-700'}`}>Saída</p>
                  <p className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>Pacotes: {device.data.matches.matcheTwo.egress.packets}</p>
                  <p className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>Bytes: {device.data.matches.matcheTwo.egress.bytes}</p>
                </div>
              </div>
            </div>
          </div>
          <style>
            {`
              .animate-pulse {
                animation: pulse 1.2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
              }
              @keyframes pulse {
                0%, 100% { opacity: 1; transform: scale(1);}
                50% { opacity: 0.7; transform: scale(1.08);}
              }
            `}
          </style>
        </>
      }
      back={
        <div className="flex flex-col items-center justify-center h-full">
            <h3 className={`flex items-center gap-2 text-lg font-bold tracking-wide ${isDarkMode ? 'text-white' : 'text-blue-900'}`}>
              <Cpu className="w-5 h-5 opacity-70" />
              {device.data.device}
            </h3>
          <p className={`mt-2 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
            {/* Exemplo de informação extra */}
            {device.data.console || 'N/A'}
          </p>
          <p className={`mt-2 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
            Sistema: {device.data.system || 'N/A'}
          </p>
          {/* Adicione mais informações conforme necessário */}
        </div>
      }
    />
  );
};

export default DeviceCard;

=======================================================

import React from 'react';
import { AlertTriangle, Cpu } from 'lucide-react';
import FlipCard from './FlipCard';

type DeviceCardNoDataProps = {
  device: any;
  isDarkMode: boolean;
};

const DeviceCardNoData: React.FC<DeviceCardNoDataProps> = ({ device, isDarkMode }) => {
  return (
    <FlipCard
      isDarkMode={isDarkMode}
      front={
        <div className="flex flex-col items-center justify-center text-center py-8">
          <AlertTriangle className={`w-12 h-12 mb-4 ${isDarkMode ? 'text-yellow-400' : 'text-yellow-500'}`} />
            <h3 className={`flex items-center gap-2 text-lg font-bold tracking-wide ${isDarkMode ? 'text-white' : 'text-blue-900'}`}>
              <Cpu className="w-5 h-5 opacity-70" />
              {device.data.device}
            </h3>
          <p className={`${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
            Não há dados disponíveis para este dispositivo no momento.
          </p>
        </div>
      }
      back={
        <div className="flex flex-col items-center justify-center h-full">
            <h3 className={`flex items-center gap-2 text-lg font-bold tracking-wide ${isDarkMode ? 'text-white' : 'text-blue-900'}`}>
              <Cpu className="w-5 h-5 opacity-70" />
              {device.data.device}
            </h3>
          <p className={`mt-2 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
            Console: {device.data.console || 'N/A'}
          </p>
        </div>
      }
    />
  );

};

export default DeviceCardNoData;


===========================================

import React, { useState, ReactNode } from 'react';

type FlipCardProps = {
  front: ReactNode;
  back: ReactNode;
  isDarkMode?: boolean;
};

const FlipCard: React.FC<FlipCardProps> = ({ front, back, isDarkMode }) => {
  const [flipped, setFlipped] = useState(false);

return (
    <div
      className={`
        relative overflow-hidden cursor-pointer
        ${isDarkMode ? 'bg-gradient-to-br from-gray-800 via-gray-900 to-gray-800' : 'bg-gradient-to-br from-white via-blue-50 to-white'}
        p-6 rounded-2xl shadow-xl border border-blue-100/30
        transition-all duration-300 hover:shadow-2xl
        before:absolute before:inset-0 before:bg-blue-400/5 before:pointer-events-none
        ${flipped ? 'rotate-y-180' : ''}
      `}
      style={{ minHeight: 320, perspective: 1000 }}
      onClick={() => setFlipped((prev) => !prev)}
    >
      <div
        className={`transition-transform duration-500 transform ${flipped ? 'rotate-y-180' : ''}`}
        style={{ transformStyle: 'preserve-3d' }}
      >
        {!flipped ? (
          <>
            {front}
          </>
        ) : (
          <>
            {back}
          </>
        )}
      </div>
      <style>
        {`
          .animate-pulse {
            animation: pulse 1.2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
          }
          @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1);}
            50% { opacity: 0.7; transform: scale(1.08);}
          }
          .rotate-y-180 {
            transform: rotateY(180deg);
          }
        `}
      </style>
    </div>
  );
};

export default FlipCard;

=======================================

import React, { useState, useEffect } from 'react';
import { useThemeStore } from '../store/themeStore';
import { X } from 'lucide-react';
import { IFilterIP, IFilterIPList } from './IpFilterDialog';
import { Device } from '@/types/data';
import { api } from '@/api/mockApi';

type DeviceFilterProps = {
  isOpen: boolean;
  onClose: () => void;
  onFilterDevice: (filters: IFilterIPList) => void;
  className: string
}

export const DeviceFilterDialog: React.FC<DeviceFilterProps> = ({ isOpen, onClose, onFilterDevice }) => {
  const [ipInputs, setIpInputs] = useState([
    { ip: '', isSourceIp: true },
  ]);
  const [error, setError] = useState('');
  const { isDarkMode } = useThemeStore();

  // Estado para lista de devices e devices selecionados
  const [devices, setDevices] = useState<Device[]>([]);
  const [selectedDevices, setSelectedDevices] = useState<string[]>([]); // array de IDs

  // Estado para loading dos devices
  const [loadingDevices, setLoadingDevices] = useState(false);

  // Buscar devices ao abrir o dialog
  useEffect(() => {
    if (isOpen) {
      setLoadingDevices(true);
      api.getListDevices().then((list) => {
        setDevices(list);
        setLoadingDevices(false);
      });
      setSelectedDevices([]); // limpa seleção ao abrir
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (ipInputs.length === 0) {
      setError('Digite pelo menos um IP');
      return;
    }
    const validIps = ipInputs.filter(input => input.ip.trim() !== '');
    if (validIps.length === 0) {
      setError('Digite pelo menos um IP válido');
      return;
    }
    if (selectedDevices.length === 0) {
      setError('Selecione pelo menos um device');
      return;
    }
    setError('');
    // Envia devices como array de string (nomes)
    onFilterDevice({ ips: validIps, devices: selectedDevices } as any);
    onClose();
  };

  const handleIpChange = (index: number, value: string) => {
    const newInputs = [...ipInputs];
    newInputs[index].ip = value;
    setIpInputs(newInputs);
  };

  const handleSourceIpChange = (index: number, checked: boolean) => {
    const newInputs = [...ipInputs];
    newInputs[index].isSourceIp = checked;
    setIpInputs(newInputs);
  };

  // Handler para seleção de devices
  const handleDeviceSelect = (deviceName: string, checked: boolean) => {
    setSelectedDevices(prev =>
      checked ? [...prev, deviceName] : prev.filter(name => name !== deviceName)
    );
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className={`${isDarkMode ? 'bg-gray-800' : 'bg-white'} rounded-lg p-6 w-[700px] relative`}>
        <button
          onClick={onClose}
          className={`absolute top-4 right-4 ${
            isDarkMode ? 'text-gray-400 hover:text-white' : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          <X className="w-5 h-5" />
        </button>
        <h2 className={`text-xl font-bold mb-4 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
         Buscar por IP e Device
        </h2>
        <form onSubmit={handleSubmit}>
          <div className="space-y-4">
            {ipInputs.map((input, index) => (
              <div key={index} className="flex items-center gap-4">
                <div className="flex-1">
                  <label className={`block text-sm font-medium mb-1 ${
                    isDarkMode ? 'text-gray-300' : 'text-gray-700'
                  }`}>
                    IP {index + 1}
                  </label>
                  <input
                    type="text"
                    value={input.ip}
                    onChange={(e) => handleIpChange(index, e.target.value)}
                    placeholder="Ex: 192.168.1.1"
                    className={`w-full p-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                      isDarkMode ? 'bg-gray-700 border-gray-600 text-white' : 'bg-white border-gray-300'
                    }`}
                  />
                </div>
                <div className="flex items-center mt-6">
                  <label className="flex items-center gap-2">
                    <input
                      type="checkbox"
                      checked={input.isSourceIp}
                      onChange={(e) => handleSourceIpChange(index, e.target.checked)}
                      className={`rounded ${
                        isDarkMode ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-300'
                      } text-blue-600`}
                    />
                    <span className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
                      IP de Origem
                    </span>
                  </label>
                </div>
              </div>
            ))}
          </div>
          {/* Seletor de devices */}
          <div className="mt-6">
            <label className={`block text-sm font-medium mb-2 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
              Selecione os Devices
            </label>
            <div className="max-h-48 overflow-y-auto border rounded-lg p-3 flex flex-col gap-2 bg-gradient-to-br from-blue-50 to-blue-100 dark:from-gray-700 dark:to-gray-800 shadow-inner">
              {loadingDevices ? (
                <div className="flex items-center justify-center py-6">
                  <svg className="animate-spin h-6 w-6 text-blue-600 dark:text-blue-300 mr-2" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4l3-3-3-3v4a8 8 0 00-8 8h4z" />
                  </svg>
                  <span className={`text-base ${isDarkMode ? 'text-gray-200' : 'text-blue-700'}`}>Carregando devices...</span>
                </div>
              ) : devices.length === 0 ? (
                <span className="text-gray-400 text-sm">Nenhum device encontrado.</span>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                  {devices.map(device => (
                    <label
                      key={device.device}
                      className={`flex items-center gap-3 px-3 py-2 rounded-lg cursor-pointer transition border border-transparent hover:border-blue-400 dark:hover:border-blue-300 ${selectedDevices.includes(device.device) ? (isDarkMode ? 'bg-blue-900/40 border-blue-400' : 'bg-blue-200/60 border-blue-500') : (isDarkMode ? 'hover:bg-gray-700/60' : 'hover:bg-blue-50')}`}
                    >
                      <input
                        type="checkbox"
                        checked={selectedDevices.includes(device.device)}
                        onChange={e => handleDeviceSelect(device.device, e.target.checked)}
                        className="accent-blue-600 w-5 h-5 rounded focus:ring-2 focus:ring-blue-400 border-gray-300 dark:border-gray-600"
                      />
                      <span className={`font-medium text-sm ${isDarkMode ? 'text-gray-100' : 'text-blue-900'}`}>{device.device}</span>
                      <span className={`ml-auto text-xs px-2 py-0.5 rounded-full ${isDarkMode ? 'bg-blue-950 text-blue-200' : 'bg-blue-100 text-blue-700'}`}>Seq: {device.sequence}</span>
                    </label>
                  ))}
                </div>
              )}
            </div>
          </div>
          {error && <p className="text-red-500 text-sm mt-2">{error}</p>}
          <button
            type="submit"
            className="w-full bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700 transition-colors mt-6"
          >
            Buscar FlowSpecs
          </button>
        </form>
      </div>
    </div>
  );
}


export type IFilterDate = {
  date: string
  ips : Array<IFilterIP>
}

===========================================
